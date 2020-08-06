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
RUN apt-get update -qy && apt-get install -qy \
        libc6 \
        libgcc-s1

RUN apt-get update -qy && apt-get install -qy \
        libgcc-s1:i386

RUN apt-get update -qy && apt-get install -qy \
        gcc-multilib \
        libc6-i386 \
        libc6:i386

# Install nvdia support files
RUN apt-get update -qy && apt-get install -qy \
        libegl-nvidia0 \
        libegl-nvidia0:i386 \
        libgl1-nvidia-glvnd-glx \
        libgl1-nvidia-glvnd-glx:i386 \
        nvidia-cg-dev \
        nvidia-cg-dev:i386 \
        nvidia-driver \
        nvidia-opencl-dev

# Install 64-bit Steam game dependencies
# (ref: https://wiki.debian.org/Steam)
RUN apt-get update -qy && apt-get install --no-install-recommends -qy \
        alsa-utils \
        gettext \
        gstreamer1.0-libav \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        libasound2 \
        libasound2-plugins \
        libattr1 \
        libbz2-1.0 \
        libcdio18 \
        libcanberra-gtk-module \
        libcdio18 \
        libcurl4 \
        libcurl4-openssl-dev \
        libdbus-1-3 \
        libdbus-glib-1-2 \
        libfaudio0 \
        libfontconfig1 \
        libfreetype6 \
        libgconf-2-4 \
        libgcrypt20 \
        libgdk-pixbuf2.0-0 \
        libgl1 \
        libgl1-mesa-dri \
        libglib2.0-0 \
        libglu1 \
        libglu1-mesa \
        libgnutls30 \
        libgpg-error0 \
        libgsm1 \
        libgssapi-krb5-2 \
        libgtk2.0-0 \
        libgstreamer-plugins-base1.0-0 \
        libgstreamer1.0-0 \
        libjpeg62-turbo \
        libjson-c4 \
        libkrb5-3 \
        libncurses6 \
        libnm0 \
        libnss3 \
        libopenal1 \
        libosmesa6 \
        libpng16-16 \
        libpulse0 \
        libquicktime2 \
        librtmp1 \
        libsdl1.2debian \
        libsdl2-2.0-0 \
        libstdc++5 \
        libstdc++6 \
        libtiff5 \
        libtinfo6 \
        libudev1 \
        libusb-1.0-0 \
        libv4l-0 \
        libvkd3d1 \
        libvulkan1 \
        libx11-6 \
        libxcb-xinput0 \
        libxcomposite1 \
        libxcursor1 \
        libxext6 \
        libxfixes3 \
        libxft2 \
        libxi6 \
        libxinerama1 \
        libxml2 \
        libxrandr2 \
        libxrender1 \
        libxslt1.1 \
        libxss1 \
        libxtst6 \
        libxv1 \
        libxvidcore4 \
        libxxf86dga1 \
        libxxf86vm1 \
        locales \
        mesa-utils \
        mesa-utils-extra \
        pulseaudio \
        pulseaudio-utils \
        x11-utils \
        zlib1g

# Install 32-bit Steam game dependencies
# (ref: https://wiki.debian.org/Steam)
RUN apt-get update -qy && apt-get install --no-install-recommends -qy \
        alsa-utils:i386 \
        gettext:i386 \
        gstreamer1.0-libav:i386 \
        gstreamer1.0-plugins-base:i386 \
        gstreamer1.0-plugins-good:i386 \
        libasound2:i386 \
        libasound2-plugins:i386 \
        libattr1:i386 \
        libcdio18:i386 \
        libbz2-1.0:i386 \
        libcanberra-gtk-module:i386 \
        libcdio18:i386 \
        libcurl4:i386 \
        libcurl4-openssl-dev:i386 \
        libdbus-1-3:i386 \
        libdbus-glib-1-2:i386 \
        libfaudio0:i386 \
        libfontconfig1:i386 \
        libfreetype6:i386 \
        libgconf-2-4:i386 \
        libgcrypt20:i386 \
        libgdk-pixbuf2.0-0:i386 \
        libgl1:i386 \
        libgl1-mesa-dri:i386 \
        libglib2.0-0:i386 \
        libglu1:i386 \
        libglu1-mesa:i386 \
        libgnutls30:i386 \
        libgpg-error0:i386 \
        libgsm1:i386 \
        libgssapi-krb5-2:i386 \
        libgtk2.0-0:i386 \
        libgstreamer-plugins-base1.0-0:i386 \
        libgstreamer1.0-0:i386 \
        libjpeg62-turbo:i386 \
        libjson-c4:i386 \
        libkrb5-3:i386 \
        libncurses6:i386 \
        libnm0:i386 \
        libnss3:i386 \
        libopenal1:i386 \
        libosmesa6:i386 \
        libpng16-16:i386 \
        libpulse0:i386 \
        libquicktime2:i386 \
        librtmp1:i386 \
        libsdl1.2debian:i386 \
        libsdl2-2.0-0:i386 \
        libstdc++5:i386 \
        libstdc++6:i386 \
        libtiff5:i386 \
        libtinfo6:i386 \
        libudev1:i386 \
        libusb-1.0-0:i386 \
        libv4l-0:i386 \
        libvkd3d1:i386 \
        libvulkan1:i386 \
        libx11-6:i386 \
        libxcb-xinput0:i386 \
        libxcomposite1:i386 \
        libxcursor1:i386 \
        libxext6:i386 \
        libxfixes3:i386 \
        libxft2:i386 \
        libxi6:i386 \
        libxinerama1:i386 \
        libxml2:i386 \
        libxrandr2:i386 \
        libxrender1:i386 \
        libxslt1.1:i386 \
        libxss1:i386 \
        libxtst6:i386 \
        libxv1:i386 \
        libxvidcore4:i386 \
        libxxf86dga1:i386 \
        libxxf86vm1:i386 \
        mesa-utils:i386 \
        mesa-utils-extra:i386 \
        pulseaudio:i386 \
        pulseaudio-utils:i386 \
        x11-utils:i386 \
        zlib1g:i386

# Workaround for games using old libraries
RUN ln -sv librtmp.so.1 /usr/lib/i386-linux-gnu/librtmp.so.0 && \
        ln -sv libudev.so.1 /usr/lib/i386-linux-gnu/libudev.so.0 && \
        ln -sv libva.so.2 /usr/lib/i386-linux-gnu/libva.so.1 && \
        ln -sv libva-drm.so.2 /usr/lib/i386-linux-gnu/libva-drm.so.1 && \
        ln -sv libva-glx.so.2 /usr/lib/i386-linux-gnu/libva-glx.so.1 && \
        ln -sv libva-wayland.so.2 /usr/lib/i386-linux-gnu/libva-wayland.so.1 && \
        ln -sv libva-x11.so.2 /usr/lib/i386-linux-gnu/libva-x11.so.1

# Install some useful packages
RUN apt-get update -qy && apt-get install -qy \
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

# Pulse workarounds
RUN echo "enable-shm = no" >> /etc/pulse/client.conf && \
    echo "autospawn = no" >> /etc/pulse/client.conf

# Workaround for steam license issues: https://askubuntu.com/questions/506909/how-can-i-accept-the-lience-agreement-for-steam-prior-to-apt-get-install/1017487#1017487
RUN echo steam steam/question select 'I AGREE' | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections

# Install the Steam package
RUN apt-get update -qy && apt-get install -qy \
        steam \
        steam-devices \
        fonts-liberation

# Install game packager and gog downloader
RUN apt-get update -qy && apt-get install -qy \
        game-data-packager \
        game-data-packager-runtime \
        lgogdownloader

# Setup dnsmasq
RUN apt-get update -qy && apt-get install -qy dnsmasq
COPY ./dnsmasq.conf /etc/dnsmasq.conf

# Setup sudo
RUN apt-get update -qy && apt-get install -qy sudo && \
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
