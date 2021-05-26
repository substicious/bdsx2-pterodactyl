#################### DEVELOPMENT ####################
FROM alpine:latest as builder


USER root

ENV ROOT="/home/container/BDSx2"

RUN mkdir -p $ROOT

RUN apk add git

RUN git clone https://github.com/bdsx/bdsx.git /home/BDSx2/

RUN cd $ROOT && \
    rm *.bat

COPY ./entrypoint.sh /home/container/BDSx2/entrypoint.sh

#################### PRODUCTION ####################
FROM ubuntu:latest as production

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -y wget gnupg2 apt-transport-https software-properties-common gpgv

RUN dpkg --add-architecture i386 && \
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    add-apt-repository -y 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' && \
    apt update

RUN DEBIAN_FRONTEND=noninteractive && \
    apt install -y --install-recommends winehq-stable mono-complete && \
    apt install -y --no-install-recommends \
    curl \
    libcurl4 \
    nano \
    nodejs \
    npm \
    screen \
    tar \
    unzip && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://dl.winehq.org/wine/wine-mono/6.1.1/wine-mono-6.1.1-x86.msi && \
    wget https://dl.winehq.org/wine/wine-gecko/2.47.2/wine-gecko-2.47.2-x86_64.msi

RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    -O /usr/bin/winetricks && \
    chmod +rx /usr/bin/winetricks && \
    winetricks win10

RUN wine64 msiexec /i wine-mono-6.1.1-x86.msi && \
    wine64 msiexec /i wine-gecko-2.47.2-x86_64.msi

RUN rm *.msi

RUN chmod +x /home/container/BDSx2/entrypoint.sh

ENV ROOT="/home/container/BDSx2"

VOLUME [ "/home/container/BDSx2" ]

COPY --from=builder $ROOT $ROOT

USER container
ENV USER=container HOME=/home/container

WORKDIR /home/container/BDSx2

CMD ["/bin/bash", "entrypoint.sh" ]
