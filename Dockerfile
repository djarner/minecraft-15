FROM openjdk:alpine

LABEL maintainer "Henrik Djarner"
LABEL date "15-5-2020"

ENV MINMEMORY=2048M
ENV MAXMEMORY=2048M

# Spigot or CraftBukkit version
ENV SERVERVERSION 1.15.2

# EULA Settings: https://account.mojang.com/documents/minecraft_eula
ENV EULA true

# UID and GID of the user minecraft
ENV UID 1000
ENV GID 1000

# EXPOSE server default port
EXPOSE 25565

# Install needed dependencies, create User, install dumb init (https://github.com/Yelp/dumb-init)
RUN apk add --no-cache -U \
    mc \
    wget \
    bash \
    sudo \HEALTHCHECK --start-period=1m CMD mc-monitor status --host localhost

RUN addgroup -g ${GID} minecraft \
  && adduser -Ss /bin/false -u ${UID} -G minecraft -h /home/minecraft minecraft \
  && mkdir -m 777 /data \
  && chown minecraft:minecraft /data /home/minecraft

# hook into docker BuildKit --platform support
# see https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG TARGETVARIANT=""

ARG EASY_ADD_VER=0.7.1
ADD https://github.com/itzg/easy-add/releases/download/${EASY_ADD_VER}/easy-add_${TARGETOS}_${TARGETARCH}${TARGETVARIANT} /usr/bin/easy-add
RUN chmod +x /usr/bin/easy-add

RUN easy-add --var os=${TARGETOS} --var arch=${TARGETARCH}${TARGETVARIANT} \
 --var version=0.1.7 --var app=mc-monitor --file {{.app}} \
 --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz

#    sed -i.bkp -e \
#      's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
#      /etc/sudoers && \

# https://papermc.io/downloads
RUN wget -O /data/minecraft.jar https://papermc.io/api/v1/paper/${SERVERVERSION}/latest/download

RUN echo "eula=${EULA}" > /data/eula.txt

WORKDIR /data

# Store for all server specific data
VOLUME ["/data"]

#USER minecraft

# Har læst at det kan hjælpe tilføje "--noconsole" til sidst for at undgå 100% CPU usage
CMD ["bash", "-c", "java -Xms${MINMEMORY} -Xmx${MAXMEMORY} -jar /data/minecraft.jar nogui --noconsole"]

    git

