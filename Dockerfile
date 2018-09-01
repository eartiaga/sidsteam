FROM debian:sid
MAINTAINER Ernest Artiaga <ernest.artiaga@eartiam.net>

ARG steam_user
ARG steam_uid

# To avoid problems with Dialog and curses wizards
ENV DEBIAN_FRONTEND noninteractive

# Enable contrib and non-free packages
RUN echo "deb http://deb.debian.org/debian sid contrib non-free" \
      >> /etc/apt/sources.list && \
    apt-get update -qy

# Enable multi-arch support
RUN dpkg --add-architecture i386 && \
    apt-get update -qy && \
    apt-get install -qy multiarch-support

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

# Setup dnsmasq
RUN apt-get install -qy dnsmasq
COPY ./dnsmasq.conf /etc/dnsmasq.conf

# Install nvdia support files
RUN apt-get install -qy \
      libaudit1:i386 \
      libgl1-nvidia-glx \
      libgl1-nvidia-glx:i386 \
      libnvidia-ml1 \
      libnvidia-ml1:i386 \
      nvidia-detect \
      nvidia-driver-bin:i386 \
      nvidia-settings:i386 \
      nvidia-smi:i386 \
      nvidia-vdpau-driver \
      nvidia-vdpau-driver:i386 \
      xserver-xorg-core:i386 \
      xserver-xorg-video-nvidia:i386

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
    adduser $USER video && \
    adduser $USER audio

# Workaround for steam license issues: https://askubuntu.com/questions/506909/how-can-i-accept-the-lience-agreement-for-steam-prior-to-apt-get-install/1017487#1017487
RUN echo steam steam/question select 'I AGREE' | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections

# Install the Steam package
RUN apt-get install -qy steam

# Install Steam game dependencies
RUN apt-get install --no-install-recommends -qy \
      libc6 \
      libcanberra-gtk-module \
      libgconf-2-4 \
      libnm-glib4 \
      libnm-util2 \
      libnss3 \
      libopenal1 \
      libpulse0 \
      libsdl1.2debian \
      libsdl2-2.0-0 \
      libstdc++5 \
      libx11-6 \
      libxss1 \
      libxv1 \
      libxvidcore4 \
      locales \
      phonon \
      pulseaudio

# Install 32-bit Steam game dependencies
# (ref: https://wiki.debian.org/Steam)
RUN apt-get install --no-install-recommends -qy \
      libasound2:i386 \
      libbz2-1.0:i386 \
      libcanberra-gtk-module:i386 \
      libcurl4:i386 \
      libcurl4-openssl-dev:i386 \
      libdbus-glib-1-2:i386 \
      libgcrypt20:i386 \
      libgdk-pixbuf2.0-0:i386 \
      libgl1-mesa-dri:i386 \
      libgl1-mesa-glx:i386 \
      libglib2.0-0:i386 \
      libgpg-error0:i386 \
      libgtk2.0-0:i386 \
      libjson-c3:i386 \
      libnm-glib4:i386 \
      libnm-util2:i386 \
      libnss3:i386 \
      libopenal1:i386 \
      libpulse0:i386 \
      libsdl1.2debian:i386 \
      libsdl2-2.0-0:i386 \
      libudev1:i386 \
      libusb-1.0-0:i386 \
      librtmp1:i386 \
      libstdc++5:i386 \
      libva-drm2:i386 \
      libva-glx2:i386 \
      libva-wayland2:i386 \
      libva-x11-2:i386 \
      libva2:i386 \
      libxrandr2:i386 \
      libxtst6:i386 \
      libxv1:i386 \
      libxvidcore4:i386 \
      phonon:i386 \
      vdpau-va-driver:i386

# Install game packager and gog downloader
RUN apt-get install -qy \
      game-data-packager \
      game-data-packager-runtime \
      lgogdownloader

# Workaround for games using old libraries
RUN ln -sv librtmp.so.1 /lib/i386-linux-gnu/librtmp.so.0 && \
    ln -sv libudev.so.1 /lib/i386-linux-gnu/libudev.so.0 && \
    ln -sv libva.so.2 /lib/i386-linux-gnu/libva.so.1 && \
    ln -sv libva-drm.so.2 /lib/i386-linux-gnu/libva-drm.so.1 && \
    ln -sv libva-glx.so.2 /lib/i386-linux-gnu/libva-glx.so.1 && \
    ln -sv libva-wayland.so.2 /lib/i386-linux-gnu/libva-wayland.so.1 && \
    ln -sv libva-x11.so.2 /lib/i386-linux-gnu/libva-x11.so.1 && \
    ln -sv librtmp.so.1 /lib/x86_64-linux-gnu/librtmp.so.0

# Obsolete libgcrypt11 work-around (for Half-Life based games)
ADD http://archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4_i386.deb /tmp/llibgcrypt11_i386.deb
ADD http://archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4_amd64.deb /tmp/llibgcrypt11_amd64.deb
RUN cd /tmp && dpkg -i *.deb && rm -f *.deb

# Pulse workarounds
RUN echo "enable-shm = no" >> /etc/pulse/client.conf

# Steam runtime
ENV STEAM_RUNTIME 1

# Start
COPY ./launch /launch
USER $USER
WORKDIR $HOME
ENTRYPOINT [ "/bin/bash", "-l", "/launch" ]
