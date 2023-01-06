# Retroarch in Docker Container

![](./overlay/usr/share/backgrounds/retroarch.png)

All credits to https://github.com/Steam-Headless/docker-steam-headless
This project was made for personal-use only, but all contributions are welcome via PRs.
The goal is to have single-docker image endpoint for retro and some-modern gaming through Moonlight (https://github.com/moonlight-stream)

## Changes from original project (docker-steam-headless):
- Ubuntu 22.04 based
- Added RetroArch via PPA
- Migrated to new Sunshine branch (from https://github.com/LizardByte/Sunshine)
- Added all mesa packages
- Deleted: SSH/dind
- No Host X server support

---
## Installation:

- [Cloning and building an image]

```
git clone https://github.com/QuaiGoner/docker-retroarch-headless && cd docker-retroarch-headless && docker build -t retroarch101 . && docker image prune -f

#Change /mnt/Games mount point to your likings in compose file

docker compose up -d

```

---
## TODO:
- More refactoring and plug&play
	- Proper version RetroArch arguments - need to fetch deb package (Where?)
	- Closing applications from Moonlight - starting is working, but not closing (Why? Same issue here: https://github.com/Steam-Headless/docker-steam-headless/issues/23)
	- Make image more lightweight with package trimming
- **Test HW Acceleration of Sunshine encoding** - seems to be working, but vainfo doesnt give anything, needs proper testing on all GPU vendors
	- AMD
	- NVIDIA
	- Intel
- **Test 3D HW Acceleration in games**
	- AMD
	- NVIDIA
	- Intel

## Long-distance TODO:
- **Rendering application window only (Wayland?)**
- EmulationStation integrated?
- Auto-scanning of /mnt/Games
- Add most-used cores to image
- Different images for different GPUs?