###########################################################
# base image, used for build stages and final images
FROM phusion/baseimage:jammy-1.0.4 AS base
RUN mkdir /build
WORKDIR /build

RUN install_clean \
        git \
        wget \
        build-essential \
        libcurl4-openssl-dev \
        libssl-dev \
        gnupg \
        libudev-dev \
        udev \
        python3 \
        python3-dev \
        python3-pip \
        nano \
        vim \
        nettle-dev

  RUN   echo -e "${RED}Finding current rdfind version${NC}" && \
        RDFIND_VERSION=$(curl --silent 'https://github.com/pauldreik/rdfind/releases' | grep 'rdfind/tree/*' | head -n 1 | sed -e 's/[^0-9\.]*//g') && \
        echo -e "${RED}Downloading rdfind $RDFIND_VERSION${NC}" && \
        set -eux && \
       # wget -O rdfind.tar.gz.sig "rdfind.pauldreik.se/$RDFIND_VERSION/rdfind-$RDFIND_VERSION-source.tar.gz.asc" && \
       # wget -O rdfind.tar.bz2 "rdfind.pauldreik.se/$RDFIND_VERSION/rdfind-$RDFIND_VERSION-source.tar.gz"
        wget -O rdfind.tar.gz.sig "rdfind.pauldreik.se/rdfind-$RDFIND_VERSION-source.tar.gz.asc" && \
        wget -O rdfind.tar.bz2 "rdfind.pauldreik.se/rdfind-$RDFIND_VERSION-source.tar.gz"



# clean up apt
RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG VERSION
ARG BUILD_DATE

