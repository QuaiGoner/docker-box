#!/usr/bin/env python3

import asyncio
import os
import signal
import subprocess
import ssl
import json
from aiohttp import web, ClientSession
from pathlib import Path
from urllib.parse import quote, unquote

HOME_DIR = "/home/default"
PORT = 31289

NOVNC_URL = "http://127.0.0.1:31100"
SELKIES_URL = "http://127.0.0.1:31101"
SUNSHINE_URL = "https://127.0.0.1:47990"

SUPERVISORCTL = "supervisorctl"
SUPERVISOR_CONF = "/etc/supervisord.conf"

ssl_ctx = ssl.create_default_context()
ssl_ctx.check_hostname = False
ssl_ctx.verify_mode = ssl.CERT_NONE


# ============================================================
# SUPERVISOR CORE
# ============================================================

def supcmd(*args):
    return subprocess.run(
        [SUPERVISORCTL, "-c", SUPERVISOR_CONF, *args],
        capture_output=True,
        text=True,
        timeout=5,
    )


def supervisor_status():
    try:
        result = supcmd("status")

        # IMPORTANT: DO NOT fail on return code 3
        output = result.stdout

        rows = []

        for line in output.splitlines():
            parts = line.split(None, 2)

            if len(parts) < 2:
                continue

            rows.append({
                "name": parts[0],
                "state": parts[1],
                "desc": parts[2] if len(parts) > 2 else ""
            })

        return rows

    except Exception as e:
        return [{"name": "ERROR", "state": "EXCEPTION", "desc": str(e)}]

def supervisor_action(name, action):
    try:
        result = supcmd(action, name)
        return result.stdout + result.stderr
    except Exception as e:
        return str(e)


def get_supervised_pids():
    pids = set()

    try:
        result = supcmd("status")

        output = result.stdout  # IMPORTANT: ignore return code

        for line in output.splitlines():
            if "pid" not in line:
                continue

            try:
                pid = int(line.split("pid")[1].split(",")[0].strip())
                pids.add(pid)
            except Exception:
                pass

    except Exception:
        pass

    return pids

def get_sunshine_clients():
    try:
        result = subprocess.run(
            [
                "curl",
                "-s",
                "-u",
                "test:test",
                "-k",
                "https://localhost:47990/api/clients/list",
            ],
            capture_output=True,
            text=True,
            timeout=5,
        )

        data = json.loads(result.stdout)

        return data.get("named_certs", [])

    except Exception:
        return []

# ============================================================
# NON-SUPERVISED PROCESSES
# ============================================================

def get_proc_info(pid):
    try:
        with open(f"/proc/{pid}/comm") as f:
            name = f.read().strip()

        try:
            with open(f"/proc/{pid}/cmdline", "rb") as f:
                cmd = f.read().replace(b"\x00", b" ").decode()
        except Exception:
            cmd = ""

        return {"pid": pid, "name": name, "cmd": cmd}

    except Exception:
        return None


def get_non_supervised():
    protected = get_supervised_pids()
    protected.update({1, os.getpid(), os.getppid()})

    out = []

    for entry in os.listdir("/proc"):
        if not entry.isdigit():
            continue

        pid = int(entry)

        if pid in protected:
            continue

        info = get_proc_info(pid)
        if info:
            out.append(info)

    return sorted(out, key=lambda x: x["pid"])


def kill_pid(pid):
    try:
        os.kill(pid, signal.SIGTERM)
    except Exception:
        pass


def kill_all_non_supervised():
    killed = []
    for p in get_non_supervised():
        try:
            os.kill(p["pid"], signal.SIGTERM)
            killed.append(p["pid"])
        except Exception:
            pass
    return killed


# ============================================================
# HTML UI
# ============================================================

def page(supervisor, processes):

    def esc(s):
        return (
            str(s)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace('"', "&quot;")
            .replace("'", "&#39;")
        )

    sup_rows = ""
    for p in supervisor:
        sup_rows += f"""
        <tr>
            <td>{esc(p["name"])}</td>
            <td class="badge-{p["state"].lower()}">{esc(p["state"])}</td>
            <td>
                <button class="start" onclick="sup('start','{p["name"]}')">Start</button>
                <button class="stop" onclick="sup('stop','{p["name"]}')">Stop</button>
                <button class="restart" onclick="sup('restart','{p["name"]}')">Restart</button>
            </td>
        </tr>
        """

    proc_rows = ""
    for p in processes:
        proc_rows += f"""
        <tr>
            <td>{p["pid"]}</td>
            <td>{esc(p["name"])}</td>
            <td>{esc(p["cmd"])}</td>
            <td><button class="kill" onclick="kill({p["pid"]})">Kill</button></td>
        </tr>
        """
    sunshine_clients = get_sunshine_clients()

    sunshine_html = ""

    for c in sunshine_clients:
        sunshine_html += f"""
        <tr>
            <td>{esc(c.get("name",""))}</td>
            <td>{esc(c.get("uuid",""))}</td>
            <td>{"✅" if c.get("enabled") else "❌"}</td>
        </tr>
        """
        
    return f"""
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Container Dashboard</title>

<style>
body {{
    margin:0;
    font-family:Arial;
    background:#0f172a;
    color:white;
}}

header {{
    padding:15px;
    background:#111827;
}}

.container {{
    padding:15px;
}}

a.button {{
    padding:10px 15px;
    background:#2563eb;
    color:white;
    text-decoration:none;
    border-radius:8px;
    margin-right:10px;
}}

table {{
    width:100%;
    border-collapse:collapse;
    background:#1e293b;
}}

th, td {{
    padding:8px;
    border-bottom:1px solid #334155;
}}

button {{
    padding:6px 10px;
    border:none;
    border-radius:6px;
    cursor:pointer;
}}

.start {{background:#16a34a; color:white;}}
.stop {{background:#dc2626; color:white;}}
.restart {{background:#2563eb; color:white;}}
.kill {{background:#f97316; color:white;}}
.killall {{background:#b91c1c; color:white; padding:10px; margin:10px 0;}}

.badge-running {{color:#22c55e;}}
.badge-stopped {{color:#ef4444;}}
.badge-fatal {{color:#f59e0b;}}
.badge-error {{color:#f97316;}}

</style>

<script>

async function sup(action, name) {{
    await fetch(`/api/supervisor/${{action}}/${{encodeURIComponent(name)}}`, {{
        method:"POST"
    }});
    location.reload();
}}

async function kill(pid) {{
    await fetch(`/api/kill/${{pid}}`, {{method:"POST"}});
    location.reload();
}}

async function killall() {{
    await fetch(`/api/kill_all`, {{method:"POST"}});
    location.reload();
}}

setTimeout(()=>location.reload(), 15000);

</script>
</head>

<body>

<header>
<h2>Container Dashboard</h2>

<a class="button" href="http://steam-novnc.krd/" target="_blank">noVNC</a>
<a class="button" href="https://steam-selkies.krd/" target="_blank">Selkies</a>
<a class="button" href="http://steam-sunshine.krd/" target="_blank">Sunshine</a>
<a class="button" href="/files/">Files</a>
</header>

<div class="container">

<h2>Sunshine</h2>

<table>
<tr>
    <th>Client</th>
    <th>UUID</th>
    <th>Enabled</th>
</tr>

{sunshine_html}

</table>

<h2>Supervisor Processes</h2>

<table>
<tr><th>Name</th><th>Status</th><th>Actions</th></tr>
{sup_rows}
</table>

<details>
<summary style="font-size:20px;cursor:pointer;margin:15px 0;">
    Non-Supervised Processes ({len(processes)})
</summary>

<button class="killall" onclick="killall()">Kill All</button>

<table>
<tr>
    <th>PID</th>
    <th>Name</th>
    <th>Command</th>
    <th>Action</th>
</tr>

{proc_rows}

</table>

</details>

</div>

</body>
</html>
"""


# ============================================================
# ROUTES
# ============================================================

routes = web.RouteTableDef()


@routes.get("/")
async def index(request):
    return web.Response(
        text=page(supervisor_status(), get_non_supervised()),
        content_type="text/html"
    )


@routes.get("/debug/supervisor")
async def dbg(request):
    return web.json_response(supervisor_status())


@routes.post("/api/supervisor/{action}/{name}")
async def sup_action(request):
    action = request.match_info["action"]
    name = request.match_info["name"]

    return web.json_response({
        "result": supervisor_action(name, action)
    })


@routes.post("/api/kill/{pid}")
async def kill_one(request):
    kill_pid(int(request.match_info["pid"]))
    return web.json_response({"ok": True})


@routes.post("/api/kill_all")
async def kill_all(request):
    return web.json_response({"killed": kill_all_non_supervised()})




@routes.get("/files/{path:.*}")
async def files(request):
    rel = unquote(request.match_info.get("path", ""))

    full = os.path.abspath(os.path.join(HOME_DIR, rel))
    home_abs = os.path.abspath(HOME_DIR)

    if not full.startswith(home_abs):
        raise web.HTTPForbidden()

    if not os.path.exists(full):
        raise web.HTTPNotFound()

    if os.path.isfile(full):
        return web.FileResponse(full)

    rows = []

    for name in sorted(os.listdir(full)):
        p = os.path.join(full, name)

        url_name = quote(name)

        if os.path.isdir(p):
            href = f"/files/{rel}/{url_name}" if rel else f"/files/{url_name}"

            rows.append(f"""
            <a class="card folder" href="{href}">
                📁 <strong>{name}</strong>
            </a>
            """)
        else:
            try:
                size = os.path.getsize(p)
            except Exception:
                size = 0

            href = (
                f"/download/{rel}/{url_name}"
                if rel
                else f"/download/{url_name}"
            )

            rows.append(f"""
            <a class="card file" href="{href}">
                📄 <strong>{name}</strong>
                <small>{size/1024:.1f} KB</small>
            </a>
            """)

    parent = "/".join(rel.split("/")[:-1])

    return web.Response(
        text=f"""
<!doctype html>
<html>
<head>
<meta charset="utf-8">

<style>
body {{
    font-family:Arial;
    background:#0f172a;
    color:white;
    margin:0;
    padding:20px;
}}

.toolbar {{
    display:flex;
    gap:10px;
    margin-bottom:20px;
}}

.button {{
    background:#2563eb;
    color:white;
    text-decoration:none;
    padding:10px 15px;
    border-radius:8px;
}}

.grid {{
    display:grid;
    grid-template-columns:repeat(auto-fill,minmax(250px,1fr));
    gap:12px;
}}

.card {{
    display:block;
    background:#1e293b;
    padding:15px;
    border-radius:12px;
    color:white;
    text-decoration:none;
}}

.card:hover {{
    background:#334155;
}}

.folder {{
    border-left:4px solid #3b82f6;
}}

.file {{
    border-left:4px solid #22c55e;
}}

small {{
    display:block;
    opacity:.7;
    margin-top:5px;
}}

#dropzone {{
    margin-bottom:20px;
    border:2px dashed #64748b;
    border-radius:12px;
    padding:40px;
    text-align:center;
    cursor:pointer;
}}

#dropzone.drag {{
    border-color:#3b82f6;
    background:#1e293b;
}}
</style>
</head>

<body>

<h2>📁 File Browser</h2>

<div class="toolbar">
    <a class="button" href="/">Dashboard</a>
    <a class="button" href="/files/{parent}">⬅ Parent</a>
</div>

<div id="dropzone">
    Drop files here or click to upload
</div>

<input id="fileinput" type="file" multiple hidden>

<div class="grid">
{''.join(rows)}
</div>

<script>

const dz = document.getElementById("dropzone");
const fi = document.getElementById("fileinput");

dz.onclick = () => fi.click();

dz.addEventListener("dragover", e => {{
    e.preventDefault();
    dz.classList.add("drag");
}});

dz.addEventListener("dragleave", () => {{
    dz.classList.remove("drag");
}});

dz.addEventListener("drop", async e => {{
    e.preventDefault();
    dz.classList.remove("drag");

    await uploadFiles(e.dataTransfer.files);
}});

fi.addEventListener("change", async () => {{
    await uploadFiles(fi.files);
}});

async function uploadFiles(files) {{

    for (const file of files) {{

        const form = new FormData();
        form.append("file", file);

        await fetch(
            "/upload/{rel}",
            {{
                method:"POST",
                body:form
            }}
        );
    }}

    location.reload();
}}

</script>

</body>
</html>
""",
        content_type="text/html",
    )


@routes.get("/download/{path:.*}")
async def download(request):
    rel = unquote(request.match_info["path"])

    full = os.path.abspath(os.path.join(HOME_DIR, rel))
    home_abs = os.path.abspath(HOME_DIR)

    if not full.startswith(home_abs):
        raise web.HTTPForbidden()

    if not os.path.isfile(full):
        raise web.HTTPNotFound()

    return web.FileResponse(
        path=full,
        headers={
            "Content-Disposition":
            f'attachment; filename="{os.path.basename(full)}"'
        }
    )


@routes.post("/upload/{path:.*}")
async def upload(request):
    rel = unquote(request.match_info.get("path", ""))

    target_dir = os.path.abspath(
        os.path.join(HOME_DIR, rel)
    )

    home_abs = os.path.abspath(HOME_DIR)

    if not target_dir.startswith(home_abs):
        raise web.HTTPForbidden()

    if not os.path.isdir(target_dir):
        raise web.HTTPNotFound()

    reader = await request.multipart()

    field = await reader.next()

    if field is None:
        return web.Response(text="No file", status=400)

    filename = os.path.basename(field.filename)

    dest = os.path.join(target_dir, filename)

    with open(dest, "wb") as f:
        while True:
            chunk = await field.read_chunk()

            if not chunk:
                break

            f.write(chunk)

    return web.json_response({
        "ok": True,
        "file": filename
    })
# ============================================================
# PROXY
# ============================================================

async def proxy(request, upstream, verify_ssl=True):
    path = request.match_info.get("tail", "")
    url = f"{upstream}/{path}"

    if request.query_string:
        url += "?" + request.query_string

    ssl_param = None if verify_ssl else ssl_ctx

    async with ClientSession() as session:
        async with session.request(
            request.method,
            url,
            data=await request.read(),
            headers={k: v for k, v in request.headers.items() if k.lower() != "host"},
            ssl=ssl_param,
        ) as resp:

            body = await resp.read()
            headers = dict(resp.headers)
            headers.pop("Transfer-Encoding", None)

            return web.Response(body=body, status=resp.status, headers=headers)

@routes.get("/debug/raw")
async def dbg_raw(request):
    import subprocess

    p = subprocess.run(
        ["supervisorctl", "status"],
        capture_output=True,
        text=True
    )

    return web.json_response({
        "code": p.returncode,
        "stdout": p.stdout,
        "stderr": p.stderr
    })

@routes.route("*", "/novnc/{tail:.*}")
async def novnc(request):
    return await proxy(request, NOVNC_URL)


@routes.route("*", "/selkies/{tail:.*}")
async def selkies(request):
    return await proxy(request, SELKIES_URL)


@routes.route("*", "/sunshine/{tail:.*}")
async def sunshine(request):
    return await proxy(request, SUNSHINE_URL, verify_ssl=False)


# ============================================================
# MAIN
# ============================================================

app = web.Application()
app.add_routes(routes)

if __name__ == "__main__":
    web.run_app(app, host="0.0.0.0", port=PORT)