# Retroarch in Docker Container

![](./overlay/usr/share/backgrounds/retroarch.png)

All credits to https://github.com/Steam-Headless/docker-steam-headless
This project was made for personal-use only, but all contributions are welcome via PRs

## Changes from original project (docker-steam-headless):
- Ubuntu 22.04 based
- Added RetroArch via PPA (supervized)
- Migrated to new Sunshine branch (from https://github.com/LizardByte/Sunshine)
- Added all mesa packages
- Deleted: SSH/Steam/dind

### USING HOST X SERVER:
If your host is already running X, you can just use that. To do this, be sure to configure:
  - DISPLAY=:0    
    **(Variable)** - *Configures the sceen to use the primary display. Set this to whatever your host is using*
  - MODE=secondary    
    **(Variable)** - *Configures the container to not start an X server of its own*
  - HOST_DBUS=true    
    **(Variable)** - *Optional - Configures the container to use the host dbus process*
  - /run/dbus:/run/dbus:ro    
    **(Mount)**  - *Optional - Configures the container to use the host dbus process*


---
## Installation:

- [Cloning and building an image]

```
git clone https://github.com/QuaiGoner/docker-retroarch-headless && cd docker-retroarch-headless && docker build -t retroarch101 . && docker image prune -f

#Change /mnt/Games mount point to your likings in compose file

docker compose up -d

```

To make retroarch proper fullscreen - just restart retroarch

---
## TODO:
- More refactoring and plug&play
	- Proper version RetroArch arguments
	- Closing and starting retroarch from Moonlight interface
- **HW Acceleration of Sunshine encoding** - seems to be working, but vainfo doesnt give anything, needs proper testing
- Proper Retroarch initialization and start-up
	- Fullscreen without restart
	- Add assets to image
- **Test 3D HW Acceleration in games**

## Long-distance TODO:
- EmulationStation integrated?
- Auto-scanning of /mnt/Games
- Add most-used cores to image
- Rendering Retroarch window only (Wayland?)
- Different images for different GPUs?
- Add back Steam (for PC gaming)