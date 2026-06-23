# docker-box (name tbd)

All credits to https://github.com/Steam-Headless/docker-steam-headless, these repo is my personal fork, with the goal to minimize internet requirements and move more to proton-based launching

## Features:
- Steam Client configured for running on Linux with Proton
- Moonlight compatible server for easy remote desktop streaming
- Easy installation of EmeDeck, Heroic and Lutris via Flatpak
- Full video/audio noVNC web access to a Xfce4 Desktop
- NVIDIA, AMD and Intel GPU support
- Full controller support
- Support for Flatpak and Appimage installation
- Root access
- Based on Debian Trixie
- Changes from original:
	- Preinstalled:
		- UMU (deb)
		- Mesa Drivers (deb)
		- Install flatpak on first run:
			- ProtonUPQT (Flatpak)
			- Protontricks (Flatpak)
			- Mozilla (Flatpak)
  - Applied tweak: Changed dummy config with edid.bin, only works for AMDGPU (thanks to https://github.com/Steam-Headless/docker-steam-headless/issues/168#issuecomment-2943219185)
  - Added selkies
  - added webui (badly vibecoded)
  - moved logs to stdout
  - deleted neko and wol
- TODO:
  - fix vaapi for steam remote play and selkies
  - investigate udev not working (linked to /dev/input:ro)
  - disable desktop, allow to install flathub apps and access files in home directory from webui
  - make image immutable, get rid of startup scripts, bake in ENVS
  - move to wayland for zerocopy and for fun
  - drop unnecessary priviliges, create small docker-compose examples
  - delete novnc
---
## Notes:

### ADDITIONAL SOFTWARE:
If you wish to install additional applications, you can generate a script inside the `~/init.d` directory ending with ".sh".
This will be executed on the container startup.

Also, you can install applications using the WebUI under **Applications > System > Software**. There you can install other game launchers like Lutris, Heroic or EmuDeck.

### STORAGE PATHS:
Everything that you wish to save in this container should be stored in the home directory or a docker container mount that you have specified. 
All files that are store outside your home directory are not persistent and will be wiped if there is an update of the container or you change something in the template.

### GAMES LIBRARY:
It is recommended that you mount your games library to `/mnt/games` and configure Steam to add that path.

### AUTO START APPLICATIONS:
In this container, Steam is configured to automatically start via supervisor. If you wish to add additional services to automatically start, 
add them under **Applications > Settings > Session and Startup** in the WebUI.

### NETWORK MODE:
If you want to use the container as a Steam Remote Play (previously "In Home Streaming") host device you should create a custom network and assign this container it's own IP, if you don't do this the traffic will be routed through the internet since Steam thinks you are on a different network.

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
- [Unraid](./docs/unraid.md)
- [Ubuntu Server](./docs/ubuntu-server.md)
- [TrueNAS SCALE](./docs/compose-files/truenas.yml)

---
