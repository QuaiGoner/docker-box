# Retroarch in Docker Container

![](./overlay/usr/share/backgrounds/retroarch.png)

## Changes from original project (docker-steam-headless):
- Ubuntu 22.10 based
- Added RetroArch (supervized)
- Migrated to new Sunshine branch (from LizardByte)
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
- [Docker Compose](./docs/docker-compose.md)



---
## TODO:
- More refactoring
- HW Acceleration of Sunshine encoding
- Different images for different GPUs
- Proper version arguments
