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

- [Cloning and building an image]

```


git clone https://github.com/QuaiGoner/docker-retroarch-headless
cd docker-retroarch-headless
docker build -t retroarch101 .
docker image prune -f
docker compose up -d
sudo chmod 777 retroarch/ && sudo chmod -R 777 retroarch/ && docker compose restart

```
I am not good with Unix permissions, so after initial docker image start we make a chmod 777 and restart container for retroarch to be able to work.
To make retroarch proper fullscreen - just restart retroarch

---
## TODO:
- More refactoring
- HW Acceleration of Sunshine encoding
- Test 3D HW Acceleration
	- Vulkan
	- OpenGL
- Different images for different GPUs
	- NVIDIA
	- AMD
	- Intel
- Fix retroarch persistence storage permissions
- Move GPU driver installation to Dockerfiles
- Proper version arguments
	- Retroarch
	- Sunshine
	- NoVNC
