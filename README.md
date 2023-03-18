# Gaming in Docker

![](./overlay/usr/share/backgrounds/docker-box.png)

All credits to https://github.com/Steam-Headless/docker-steam-headless
This project was made for personal-use only, but all contributions are welcome via PRs.

The goal is to have single-docker image endpoint for retro and some-modern gaming through Moonlight (https://github.com/moonlight-stream) with (maybe) multi-client support.

## Changes from original project (docker-steam-headless):
- Ubuntu 22.04 based
- Added EmulationStation-DE (from https://gitlab.com/es-de/emulationstation-de)
- Added RetroArch via PPA
- Added PCSX2 via PPA
- Added XEMU via PPA
- Added RPCS3 via appimage
- Migrated to new Sunshine branch (from https://github.com/LizardByte/Sunshine)
- Added all mesa packages
- Deleted: SSH/dind
- No Host X server support

---
## Installation:

- [Building and starting a container]

```
git clone https://github.com/QuaiGoner/docker-box && cd docker-box && docker build -t docker-box .

#Change /home/default/ROMs/ mountpoint to your likings in compose file

docker compose up -d

```

---
## TODO:
- More refactoring and plug&play
	- **Need Help:** **Closing applications from Moonlight with retaining session** - starting is working, but not closing. Also when pausing session in moonligt - app gets killed (Simillar issue here: https://github.com/Steam-Headless/docker-steam-headless/issues/23)
	- **Need Help:** Resolve High CPU Usage (i guess because of a dummy xorg driver. Probably will be fixed with Wayland)
	- Restart ES on exit
    - Get rid of many sh init scripts (move to entrypoint or Dockerfile)
- Add More Emulators
	- Wine/Lutris for Windows Games
	- Xenia
	- Preinstall more cores to RA
- Github workflows
	- Build and publish latest image
	- Dockerfile testing
	- Shell testing

## Long-distance TODO:
- **Rendering application window only (Wayland?)**
- **Test HW Acceleration of Sunshine encoding** - seems to be working, but vainfo doesnt give anything, needs proper testing on all GPU vendors
	- AMD
	- NVIDIA
	- Intel
- **Test 3D HW Acceleration in games**
	- AMD
	- NVIDIA
	- Intel
- Make image more lightweight with package trimming
- Create virtual application windows dimensions based on the client (Resolution/HDR, now its hardcoded in xorg.conf and ENV) or in docker-compose
- Different images for different GPUs?
- **Multi-tenant**
