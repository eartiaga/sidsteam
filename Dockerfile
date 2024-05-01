FROM debian:sid-slim
MAINTAINER Ernest Artiaga <ernest.artiaga@eartiam.net>

ARG STEAM_USER
ARG STEAM_UID

# Avoid issues with Dialog and curses wizards
ENV DEBIAN_FRONTEND noninteractive

# Enable contrib and non-free packages
RUN echo "deb http://deb.debian.org/debian sid main contrib non-free" \
    >> /etc/apt/sources.list

COPY ./steam.dep /tmp/steam.dep
COPY ./tools.dep /tmp/tools.dep

# Prepare the system
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update -qy && \
    apt-get upgrade -qy && \
    awk '$1 ~ /^[^#]/' /tmp/tools.dep | \
    xargs apt-get install -qy && \
    apt-get autoremove -qy && \
    apt-get clean && \
    rm -rf /var/list/apt/lists/*

# Add official steam repository
RUN curl -s http://repo.steampowered.com/steam/archive/stable/steam.gpg | \
    tee /usr/share/keyrings/steam.gpg > /dev/null && \
    echo deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] \
        http://repo.steampowered.com/steam/ stable steam | \
    tee /etc/apt/sources.list.d/steam.list

# Enable i386 architecture
# Note: the install must be done separately and in the proper order
RUN dpkg --add-architecture i386 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update -qy && \
    awk '$1 ~ /^[^#]/' /tmp/steam.dep | \
    xargs apt-get install -qy && \
    awk '$1 ~ /^[^#]/ {print $1 ":i386"}' /tmp/steam.dep | \
    xargs apt-get install -qy && \
    apt-get install -qy steam-launcher && \
    rm -f /etc/apt/sources.list.d/steam-beta.list && \
    rm -f /etc/apt/sources.list.d/steam-stable.list && \
    apt-get autoremove -qy && \
    apt-get clean && \
    rm -rf /var/list/apt/lists/*

# Pulse workarounds
RUN echo "enable-shm = no" >> /etc/pulse/client.conf && \
    echo "autospawn = no" >> /etc/pulse/client.conf

# Setup dnsmasq
COPY ./dnsmasq.conf /etc/dnsmasq.conf

# Setup sudo
RUN echo "$STEAM_USER ALL = NOPASSWD: ALL" > /etc/sudoers.d/sidsteam && \
    chmod 440 /etc/sudoers.d/sidsteam

# User setup
ENV USER $STEAM_USER
ENV UID $STEAM_UID
ENV HOME /home/$STEAM_USER
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
