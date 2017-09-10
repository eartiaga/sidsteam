FROM debian:sid
MAINTAINER Ernest Artiaga <ernest.artiaga@eartiam.net>

ARG steam_user
ARG steam_uid

# To avoid problems with Dialog and curses wizards
ENV DEBIAN_FRONTEND noninteractive

# Enable Multi-Arch and non-free packages
RUN echo "deb http://deb.debian.org/debian sid contrib non-free" \
      >> /etc/apt/sources.list && \
    dpkg --add-architecture i386 && \
    apt-get clean && \
    apt-get update -qy && \
    apt-get upgrade -qy

# Install some useful packages
RUN apt-get install -qy zenity curl dnsmasq gnupg sudo net-tools attr xattr && \
    echo "$steam_user ALL = NOPASSWD: ALL" > /etc/sudoers.d/sidsteam && \
    chmod 440 /etc/sudoers.d/sidsteam
COPY ./dnsmasq.conf /etc/dnsmasq.conf

# Install NVidia support files
RUN apt-get install -qy nvidia-driver

# Enable Steam repo
RUN echo \
    "deb [arch=amd64,i386] http://repo.steampowered.com/steam/ precise steam" \
      > /etc/apt/sources.list.d/bootstrap-steampowered.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
      --recv 0xF24AEA9FB05498B7 && \
    apt-get update -qy

# Install the Steam package
RUN apt-get install -qy steam-launcher && \
    rm -f /etc/apt/sources.list.d/bootstrap-steampowered.list && \
    apt-get update -qy
ENV STEAM_RUNTIME 1

# Install Steam dependencies
RUN apt-get install -qy \
      locales libgconf-2-4 \
      libstdc++5 libc6 \
      libnm-util2 libnm-glib4 libnss3 \
      pulseaudio libpulse0 \
      libxss1 libsdl2-2.0-0:i386 && \
    apt-get install -qy \
      libx11-6 \
      libgl1-mesa-dri:i386 libgl1-mesa-glx:i386 \
      libsdl2-2.0-0:i386 \
      libopenal1:i386 libpulse0:i386 libasound2:i386 libasound2-plugins:i386 \
      libusb-1.0-0:i386 libudev1:i386 libdbus-glib-1-2:i386 \
      libstdc++5:i386 \
      libglib2.0-0:i386 libgtk2.0-0:i386 libcanberra-gtk-module:i386 \
      libnm-util2:i386 libnm-glib4:i386 libnss3:i386 \
      librtmp1:i386 \
      libgcrypt20:i386 \
      libjson-c3:i386 \
      libbz2-1.0:i386 \
      libcurl3:i386 && \
    ln -sv libudev.so.1 /lib/i386-linux-gnu/libudev.so.0 && \
    ln -sv librtmp.so.1 /lib/i386-linux-gnu/librtmp.so.0 && \
    ln -sv librtmp.so.1 /lib/x86_64-linux-gnu/librtmp.so.0

# Pulse workarounds
RUN echo "enable-shm = no" >> /etc/pulse/client.conf

# Obsolete libgcrypt11 work-around (for Half-Life based games)
ADD http://archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4_i386.deb /tmp/llibgcrypt11_i386.deb
ADD http://archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4_amd64.deb /tmp/llibgcrypt11_amd64.deb
RUN cd /tmp && dpkg -i *.deb && rm -f *.deb

# User setup
ENV USER $steam_user
ENV UID $steam_uid
ENV HOME /home/$steam_user
RUN adduser --disabled-password --gecos 'Steam User' \
      --home "$HOME" --uid "$UID" $USER && \
    adduser $USER video && \
    adduser $USER audio

WORKDIR $HOME

# Launch steam
COPY ./launch /launch
ENTRYPOINT [ "/bin/bash", "/launch" ]
