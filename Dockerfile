FROM debian:bookworm-slim

USER root

ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod 0755 /usr/bin/tini

# Enable non-free repo and i386 arch for steamcmd
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        software-properties-common && \
    add-apt-repository \
        -U http://deb.debian.org/debian \
        -c non-free-firmware \
        -c non-free && \
    dpkg --add-architecture i386 && \
    apt-get clean

# Pre-accept the steam license agreement
RUN echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections

# Install wine, steamcmd, and required libraries
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install --no-install-recommends -y \
         wine wine32 wine64 xvfb xauth steamcmd curl && \
    apt-get clean
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Install Icarus server using steamcmd
RUN mkdir -p /home/steam/steamcmd/icarus && \
    steamcmd +login anonymous +force_install_dir /home/steam/steamcmd/icarus +app_update 2089300 validate +quit

# Copy the launch script for the Icarus server
COPY launch_server.sh /usr/bin/launch_server
RUN chmod 0755 /usr/bin/launch_server

# Set environment variables and directories
ENV SERVER_DIR=/home/steam/steamcmd/icarus
ENV WINEPREFIX=/home/steam/.wine
ENV DISPLAY=:0

# Expose the required ports for Icarus
EXPOSE 17777/udp 27016/udp

# Use Tini as init system to ensure cleanup
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/bin/launch_server"]
