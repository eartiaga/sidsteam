FROM debian:sid-slim
MAINTAINER Ernest Artiaga <ernest.artiaga@eartiam.net>

ARG steam_user=steam
ARG steam_uid=1001

# Avoid issues with Dialog and curses wizards
ENV DEBIAN_FRONTEND noninteractive

# Enable contrib and non-free packages
RUN echo "deb http://deb.debian.org/debian sid contrib non-free" \
        >> /etc/apt/sources.list && \
        apt-get update -qy

# Enable i386 architecture
RUN dpkg --add-architecture i386 && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \
        apt-get update -qy

# Install basic i386 support
RUN apt-get install -qy \
        gcc-multilib \
        libc6-i386 \
        libc6:i386

# Install some useful packages
RUN apt-get install -qy \
        apt \
        attr \
        curl \
        gnupg \
        lxterminal \
        net-tools \
        p7zip \
        p7zip-rar \
        xattr \
        zenity

# Install nvdia support files
RUN apt-get install -qy \
        libegl-nvidia0 \
        libegl-nvidia0:i386 \
        libgl1-nvidia-glvnd-glx \
        libgl1-nvidia-glvnd-glx:i386 \
        nvidia-cg-dev \
        nvidia-cg-dev:i386 \
        nvidia-driver \
        nvidia-driver-libs \
        nvidia-driver-libs:i386 \
        nvidia-opencl-dev

# Install 64-bit Steam game dependencies
# (ref: https://wiki.debian.org/Steam)
RUN apt-get install --no-install-recommends -qy \
        alsa-utils \
        libasound2 \
        libasound2-plugins \
        libbz2-1.0 \
        libc6 \
        libcanberra-gtk-module \
        libcurl4 \
        libcurl4-openssl-dev \
        libdbus-glib-1-2 \
        libgconf-2-4 \
        libgcrypt20 \
        libgdk-pixbuf2.0-0 \
        libglu1 \
        libglib2.0-0 \
        libgpg-error0 \
        libgtk2.0-0 \
        libjson-c4 \
        libnm0 \
        libnss3 \
        libopenal1 \
        libpulse0 \
        libsdl1.2debian \
        libsdl2-2.0-0 \
        libudev1 \
        libusb-1.0-0 \
        librtmp1 \
        libstdc++5 \
        libstdc++6 \
        libx11-6 \
        libxrandr2 \
        libxss1 \
        libxtst6 \
        libxv1 \
        libxvidcore4 \
        locales \
        mesa-utils \
        mesa-utils-extra \
        pulseaudio \
        pulseaudio-utils \
        x11-utils

# Install 32-bit Steam game dependencies
# (ref: https://wiki.debian.org/Steam)
RUN apt-get install --no-install-recommends -qy \
        alsa-utils:i386 \
        libasound2:i386 \
        libasound2-plugins:i386 \
        libbz2-1.0:i386 \
        libc6:i386 \
        libcanberra-gtk-module:i386 \
        libcurl4:i386 \
        libcurl4-openssl-dev:i386 \
        libdbus-glib-1-2:i386 \
        libgconf-2-4:i386 \
        libgcrypt20:i386 \
        libgdk-pixbuf2.0-0:i386 \
        libglu1:i386 \
        libglib2.0-0:i386 \
        libgpg-error0:i386 \
        libgtk2.0-0:i386 \
        libjson-c4:i386 \
        libnm0:i386 \
        libnss3:i386 \
        libopenal1:i386 \
        libpulse0:i386 \
        libsdl1.2debian:i386 \
        libsdl2-2.0-0:i386 \
        libudev1:i386 \
        libusb-1.0-0:i386 \
        librtmp1:i386 \
        libstdc++5:i386 \
        libstdc++6:i386 \
        libx11-6:i386 \
        libxrandr2:i386 \
        libxss1:i386 \
        libxtst6:i386 \
        libxv1:i386 \
        libxvidcore4:i386 \
        mesa-utils:i386 \
        mesa-utils-extra:i386 \
        pulseaudio:i386 \
        pulseaudio-utils:i386 \
        x11-utils:i386

# Workaround for games using old libraries
RUN ln -sv librtmp.so.1 /usr/lib/i386-linux-gnu/librtmp.so.0 && \
        ln -sv libudev.so.1 /usr/lib/i386-linux-gnu/libudev.so.0 && \
        ln -sv libva.so.2 /usr/lib/i386-linux-gnu/libva.so.1 && \
        ln -sv libva-drm.so.2 /usr/lib/i386-linux-gnu/libva-drm.so.1 && \
        ln -sv libva-glx.so.2 /usr/lib/i386-linux-gnu/libva-glx.so.1 && \
        ln -sv libva-wayland.so.2 /usr/lib/i386-linux-gnu/libva-wayland.so.1 && \
        ln -sv libva-x11.so.2 /usr/lib/i386-linux-gnu/libva-x11.so.1

# Pulse workarounds
RUN echo "enable-shm = no" >> /etc/pulse/client.conf && \
    echo "autospawn = no" >> /etc/pulse/client.conf

# Workaround for steam license issues: https://askubuntu.com/questions/506909/how-can-i-accept-the-lience-agreement-for-steam-prior-to-apt-get-install/1017487#1017487
RUN echo steam steam/question select 'I AGREE' | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections

# Install the Steam package
RUN apt-get install -qy steam steam-devices fonts-liberation

# Install game packager and gog downloader
RUN apt-get install -qy \
        game-data-packager \
        game-data-packager-runtime \
        lgogdownloader

# Setup dnsmasq
RUN apt-get install -qy dnsmasq
COPY ./dnsmasq.conf /etc/dnsmasq.conf

# Setup sudo
RUN apt-get install -qy sudo && \
        echo "$steam_user ALL = NOPASSWD: ALL" > /etc/sudoers.d/sidsteam && \
        chmod 440 /etc/sudoers.d/sidsteam

# User setup
ENV USER $steam_user
ENV UID $steam_uid
ENV HOME /home/$steam_user
RUN adduser --disabled-password --gecos 'Steam User' \
        --home "$HOME" --uid "$UID" $USER && \
        adduser $USER audio && \
        adduser $USER cdrom && \
        adduser $USER video && \
        mkdir -p "$HOME/data" && \
        chown "${USER}.${USER}" "$HOME/data"

# Clean up
RUN apt-get upgrade -qy && apt-get autoremove -qy

# Obsolete libgcrypt11 work-around (for Half-Life based games)
ADD http://archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4.6_i386.deb /tmp/libgcrypt11_i386.deb
RUN cd /tmp && dpkg --force-depends -i *.deb && rm -f *.deb

# Steam runtime
ENV STEAM_RUNTIME 1

# Start
COPY ./launch /launch
USER $USER
WORKDIR $HOME
ENTRYPOINT [ "/bin/bash", "-l", "/launch" ]
