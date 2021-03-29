FROM debian:sid-slim
MAINTAINER Ernest Artiaga <ernest.artiaga@eartiam.net>

ARG steam_user=steam
ARG steam_uid=1001

# Avoid issues with Dialog and curses wizards
ENV DEBIAN_FRONTEND noninteractive

# Enable contrib and non-free packages
RUN echo "deb http://deb.debian.org/debian sid contrib non-free" \
        >> /etc/apt/sources.list

# Enable i386 architecture
# Note: the install must be done separately and in the proper order
RUN dpkg --add-architecture i386 && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \
        apt-get update -qy && \
        apt-get install -qy libc6 libgcc-s1 && \
        apt-get install -qy libgcc-s1:i386 && \
        apt-get install -qy gcc-multilib libc6-i386 libc6:i386 && \
        apt-get autoremove -qy && \
        rm -rf /var/lib/apt/lists/*

# Workaround for steam license issues: https://askubuntu.com/questions/506909/how-can-i-accept-the-lience-agreement-for-steam-prior-to-apt-get-install/1017487#1017487
RUN echo steam steam/question select 'I AGREE' | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections

# Dependency lists
COPY ./packages.dep /tmp/packages.dep
COPY ./steam.dep /tmp/steam.dep
COPY ./steam_i386.dep /tmp/steam_i386.dep

# Install basic packages and dependencies
RUN apt-get update -qy && \
        awk '$1 ~ /^[^#]/' /tmp/packages.dep | \
        xargs apt-get install -qy && \
        awk '$1 ~ /^[^#]/' /tmp/steam.dep | \
        xargs apt-get install -qy && \
        awk '$1 ~ /^[^#]/ {print $1 ":i386"}' /tmp/steam.dep | \
        xargs apt-get install -qy && \
        awk '$1 ~ /^[^#]/ {print $1 ":i386"}' /tmp/steam_i386.dep | \
        xargs apt-get install -qy && \
        apt-get autoremove -qy && \
        rm -rf /var/lib/apt/lists/*

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

# Setup dnsmasq
COPY ./dnsmasq.conf /etc/dnsmasq.conf

# Setup sudo
RUN echo "$steam_user ALL = NOPASSWD: ALL" > /etc/sudoers.d/sidsteam && \
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
