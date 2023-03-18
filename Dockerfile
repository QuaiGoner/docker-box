FROM ubuntu:22.04
LABEL maintainer="QuaiGoner (kr052997@gmail.com)"
RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/London apt-get update && apt-get -y install tzdata keyboard-configuration
# Install core packages
RUN \
    echo "**** Update apt database ****" \
        && apt-get update
RUN \
    echo "**** Install tools and repos ****" \
        && apt-get install -y --no-install-recommends \
            software-properties-common \
            apt-utils \
			gpg-agent \
			locales \
        && add-apt-repository ppa:libretro/stable \
		&& dpkg --add-architecture i386 \
	    && echo "**** Install and configure locals ****" \
        && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
        && locale-gen
RUN \
    echo "**** Install all required (mesa/vulkan/desktop/audio/drivers) packages ****" \
        && apt-get install -y --no-install-recommends \
            bash \
            bash-completion \
            curl \
            git \
            less \
            man-db \
            mlocate \
            nano \
            net-tools \
            patch \
            pciutils \
            pkg-config \
            procps \
            rsync \
            screen \
            sudo \
            unzip \
            p7zip-full \
            vim \
            wget \
            xz-utils \
            python3 \
            python3-numpy \
            python3-pip \
            python3-setuptools \
			nginx \
			ffmpeg \
# Mesa packages
            libgl1-mesa-dri \
            libgl1-mesa-glx \
            libgles2-mesa \
            libglu1-mesa \
            mesa-utils \
            mesa-utils-extra \
			mesa-* \
# Vulkan packages
            libvulkan1 \
            mesa-vulkan-drivers \
            vulkan-tools \
# Desktop dependencies
            libdbus-1-3 \
            libegl1 \
            libgtk-3-0 \
            libgtk2.0-0 \
            libsdl2-2.0-0 \
            avahi-utils \
            dbus-x11 \
            libxcomposite-dev \
            libxcursor1 \
            x11-xfs-utils \
            x11vnc \
            xauth \
            xfonts-base \
            xorg \
            xserver-xorg-core \
            xserver-xorg-input-evdev \
            xserver-xorg-input-libinput \
            xserver-xorg-legacy \
            xserver-xorg-video-all \
            xserver-xorg-video-dummy \
            xvfb \
# Desktop environment
            xfce4 \
            xfce4-terminal \
            fonts-vlgothic \
            gedit \
# Install audio requirements
            pulseaudio \
            alsa-utils \
            libasound2 \
            libasound2-plugins \
# Install audio support
            bzip2 \
            gstreamer1.0-alsa \
            gstreamer1.0-gl \
            gstreamer1.0-gtk3 \
            gstreamer1.0-libav \
            gstreamer1.0-plugins-bad \
            gstreamer1.0-plugins-base \
            gstreamer1.0-plugins-good \
            gstreamer1.0-plugins-ugly \
            gstreamer1.0-pulseaudio \
            gstreamer1.0-qt5 \
            gstreamer1.0-tools \
            gstreamer1.0-vaapi \
            gstreamer1.0-x \
            libgstreamer1.0-0 \
            libncursesw5 \
            libopenal1 \
            libsdl-image1.2 \
            libsdl-ttf2.0-0 \
            libsdl1.2debian \
            libsndfile1 \
            ucspi-tcp \
# Media drivers and VAINFO
            libva2 \
            vainfo \
			i965-va-driver-shaders \
# Install supervisor
			supervisor
			
# Install EmulationStaion_DE
RUN \
    echo "**** Install ESDE ****" \
        && wget -O /tmp/esde.deb https://gitlab.com/es-de/emulationstation-de/-/package_files/71412450/download \
        && apt install -y /tmp/esde.deb
		
# Install PCSX2
RUN add-apt-repository -y ppa:pcsx2-team/pcsx2-daily && \
    apt-get update && \
    apt-get install -y pcsx2-unstable && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common gpg-agent && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Install XEMU
RUN add-apt-repository -y ppa:mborgerson/xemu && \
    apt-get update && \
    apt-get install -y xemu && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common gpg-agent && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
	
# Install RPCS3
RUN \
    echo "**** Install RPCS3 ****" && \
        mkdir /home/default/Applications && \
        cd /home/default/Applications && \
        wget -O rpcs3-emu.AppImage https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-6809d84a0029377eab059a51ce38f440e325be1c/rpcs3-v0.0.26-14564-6809d84a_linux64.AppImage && \
        chmod +x /home/default/Applications/rpcs3-emu.AppImage		
		
# Install Retroarch
RUN \
    echo "**** Install Retroarch ****" \
        && apt-get update \
        && apt-get install -y \
			libusb-1.0-0 \
			libglu1-mesa \
			libaio1 \
			libaio-dev \
			retroarch \
			retroarch-assets \
			libretro-*
# Install NOVNC
ARG NOVNC_VERSION=1.2.0
RUN \
    echo "**** Fetch noVNC ****" \
        && cd /tmp \
        && wget -O /tmp/novnc.tar.gz https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz \
    && \
    echo "**** Extract noVNC ****" \
        && cd /tmp \
        && tar -xvf /tmp/novnc.tar.gz \
    && \
    echo "**** Configure noVNC ****" \
        && cd /tmp/noVNC-${NOVNC_VERSION} \
        && sed -i 's/credentials: { password: password } });/credentials: { password: password },\n                           wsProtocols: ["'"binary"'"] });/g' app/ui.js \
        && mkdir -p /opt \
        && rm -rf /opt/noVNC \
        && cd /opt \
        && mv -f /tmp/noVNC-${NOVNC_VERSION} /opt/noVNC \
        && cd /opt/noVNC \
        && ln -s vnc.html index.html \
        && chmod -R 755 /opt/noVNC \
    && \
    echo "**** Modify noVNC title ****" \
        && sed -i '/    document.title =/c\    document.title = "docker-box - noVNC";' \
            /opt/noVNC/app/ui.js
# Install Websocify
ARG WEBSOCKETIFY_VERSION=0.10.0
RUN \
    echo "**** Fetch Websockify ****" \
        && cd /tmp \
        && wget -O /tmp/websockify.tar.gz https://github.com/novnc/websockify/archive/v${WEBSOCKETIFY_VERSION}.tar.gz \
    && \
    echo "**** Extract Websockify ****" \
        && cd /tmp \
        && tar -xvf /tmp/websockify.tar.gz \
    && \
    echo "**** Install Websockify to main ****" \
        && cd /tmp/websockify-${WEBSOCKETIFY_VERSION} \
        && python3 ./setup.py install \
    && \
    echo "**** Install Websockify to noVNC path ****" \
        && cd /tmp \
        && mv -v /tmp/websockify-${WEBSOCKETIFY_VERSION} /opt/noVNC/utils/websockify
# Install Sunshine
ARG SUNSHINE_VERSION=0.18.4
RUN \
    echo "**** Fetch Sunshine deb package ****" \
        && cd /tmp \
        && wget -O /tmp/sunshine-22.04.deb \
		    https://github.com/LizardByte/Sunshine/releases/download/v${SUNSHINE_VERSION}/sunshine-ubuntu-22.04-amd64.deb \
    && \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install Sunshine ****" \
        && apt-get install -y /tmp/sunshine-22.04.deb \
    && \
    echo "**** Section cleanup ****" \
        && apt-get clean autoclean -y \
        && apt-get autoremove -y \
        && rm -rf \
            /var/lib/apt/lists/* \
            /var/tmp/* \
            /tmp/*
# Configure default user and set env
ENV \
    PUID=99 \
    PGID=100 \
    UMASK=000 \
    USER="default" \
    USER_PASSWORD="password" \
    USER_HOME="/home/default" \
    TZ="Asia/Novosibirsk" \
    USER_LOCALES="en_US.UTF-8 UTF-8"
RUN \
    echo "**** Configure default user '${USER}' ****" \
        && mkdir -p \
            ${USER_HOME} \
        && useradd -d ${USER_HOME} -s /bin/bash ${USER} \
        && chown -R ${USER} \
            ${USER_HOME} \
        && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && \
    echo

# Add FS overlay
COPY overlay /
		
# Set display environment variables
ENV \
    DISPLAY_CDEPTH="24" \
    DISPLAY_DPI="96" \
    DISPLAY_REFRESH="60" \
    DISPLAY_SIZEH="1080" \
    DISPLAY_SIZEW="1920" \
    DISPLAY_VIDEO_PORT="DFP" \
    DISPLAY=":55" \
    NVIDIA_DRIVER_CAPABILITIES="all" \
    NVIDIA_VISIBLE_DEVICES="all" \
    XORG_SOCKET_DIR="/tmp/.X11-unix" \
    XDG_RUNTIME_DIR="/tmp/.X11-unix/run"

# Set pulseaudio environment variables
ENV \
    PULSE_SOCKET_DIR="/tmp/pulse" \
    PULSE_SERVER="unix:/tmp/pulse/pulse-socket"

# Set container configuration environment variables
ENV \
    MODE="primary" \
    WEB_UI_MODE="vnc" \
    ENABLE_VNC_AUDIO="true" \
    ENABLE_SUNSHINE="true" \
    ENABLE_EVDEV_INPUTS="true"

# Configure required ports
ENV \
    PORT_NOVNC_WEB="8083"

# Expose the required ports
EXPOSE 8083

# Set entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]