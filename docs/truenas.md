services:
  steam-headless:
    cap_add:
      - AUDIT_WRITE
      - CHOWN
      - DAC_OVERRIDE
      - FOWNER
      - FSETID
      - KILL
      - MKNOD
      - NET_ADMIN
      - SETGID
      - SETUID
      - SYS_ADMIN
      - SYS_NICE
      - SYS_RESOURCE
    container_name: steam-headless
    deploy:
      resources:
        limits:
          cpus: '3'
          memory: 5096M
    device_cgroup_rules:
      - c 13:* rwm
      - c 226:* rwm
    devices:
      - /dev/dri:/dev/dri
      - /dev/fuse:/dev/fuse
      - /dev/uinput:/dev/uinput
    environment:
      DISPLAY: ':0'
      ENABLE_EVDEV_INPUTS: 'true'
      ENABLE_STEAM: 'true'
      ENABLE_SUNSHINE: 'true'
      ENABLE_VNC_AUDIO: 'true'
      FORCE_X11_DUMMY_CONFIG: 'false'
      GID: '568'
      GROUP_ID: '568'
      HOST_DBUS: 'true'
      HOST_HOSTNAME: server101
      HOST_OS: TrueNAS
      MODE: primary
      PGID: '568'
      PORT_NOVNC_WEB: '31100'
      PUID: '568'
      STEAM_ARGS: '-silent'
      SUNSHINE_PASS: 123
      SUNSHINE_USER: 123
      UID: '568'
      UMASK: '002'
      UMASK_SET: '002'
      USER_ID: '568'
      USER_LOCALES: en_US.UTF-8 UTF-8
      USER_PASSWORD: 123
      WEB_UI_MODE: vnc
    extra_hosts:
      server101: 127.0.0.1
    group_add:
      - 44
      - 107
      - 568
    hostname: server101
    image: josh5/steam-headless:debian
    ipc: host
    network_mode: host
    privileged: True
    restart: unless-stopped
    security_opt:
      - apparmor=unconfined
      - seccomp=unconfined
    shm_size: 2048M
    ulimits:
      nofile:
        hard: 524288
        soft: 1024
    volumes:
      - /mnt/apps101/docker101/steamheadless/home:/home/default:rw
      - /mnt/apps101/docker101/steamheadless/games:/mnt/games:rw
      - /run/dbus:/run/dbus:ro
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
      - /tmp/pulse:/tmp/pulse:rw
      - /dev/input/:/dev/input/:ro
