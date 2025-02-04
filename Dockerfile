FROM debian:bookworm-slim

USER root

ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod 0755 /usr/bin/tini

# enable non-free repo and i386 arch for steamcmd
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

# pre-accept the steam license agreement
RUN echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install --no-install-recommends -y \
         wine wine32 wine64 xvfb xauth steamcmd && \
    apt-get clean
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Copy in the launch server script
COPY launch_server.sh /usr/bin/launch_server
RUN chmod 0755 /usr/bin/launch_server

ENTRYPOINT ["/usr/bin/launch_server"]
