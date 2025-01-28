###########################################################
# base image, used for build stages and final images
#FROM phusion/baseimage:jammy-1.0.4 AS base
FROM debian:bookworm-slim AS base
RUN mkdir /build
WORKDIR /build

RUN apt-get update && apt-get install autoconf build-essential nettle-dev libcap2-bin wget curl  --yes
#RUN install_clean \
#        git \
#        wget \
#        build-essential \
#        libcurl4-openssl-dev \
#        libssl-dev \
#        gnupg \    
#	 libcap2-bin \
#	 autoconf \
#        nettle-dev


  RUN   echo -e "${RED}Finding current rdfind version${NC}" && \
        RDFIND_VERSION=$(curl --silent 'https://github.com/pauldreik/rdfind/releases' | grep 'rdfind/tree/*' | head -n 1 | sed -e 's/[^0-9\.]*//g') && \
        echo -e "${RED}Downloading rdfind $RDFIND_VERSION${NC}" && \
        set -eux && \
       # wget -O rdfind.tar.gz.sig "rdfind.pauldreik.se/$RDFIND_VERSION/rdfind-$RDFIND_VERSION-source.tar.gz.asc" && \
       # wget -O rdfind.tar.bz2 "rdfind.pauldreik.se/$RDFIND_VERSION/rdfind-$RDFIND_VERSION-source.tar.gz"
        wget -O rdfind.tar.gz.sig "rdfind.pauldreik.se/rdfind-$RDFIND_VERSION.tar.gz.asc" && \
        wget -O rdfind.tar.bz2 "rdfind.pauldreik.se/rdfind-$RDFIND_VERSION.tar.gz" && \
        GNUPGHOME="$(mktemp -d)" && export GNUPGHOME && \
	gpg ---batch -keyserver keyserver.ubuntu.com --recv-keys 0xcc3c51ba88205b19728a6f07c9d9a0ea44eae0eb && \
        gpg --batch --verify rdfind.tar.gz.sig rdfind.tar.bz2; rm -rf "$GNUPGHOME" rdfind.tar.gz.sig && \
        mkdir -p /tmp/rdfind && \
        tar --extract \
	        --file rdfind.tar.bz2 \
	        --directory /tmp/rdfind \
	        --strip-components 1 && \
        rm rdfind.tar.bz2 && \
        cd /tmp/rdfind && \
        ./configure --enable-warnings CXXFLAGS=-std=c++17&& \
        make && \
        #make check && \
	make distcheck CXXFLAGS=-std=c++17 && \
 	make clean  && \
        eval $(DEB_CXXFLAGS_APPEND=-std=c++17 DEB_BUILD_MAINT_OPTIONS="hardening=+all qa=+all,-canary reproducible=+all" dpkg-buildflags --export=sh) && \
        ./configure && \
        make 
	#&& \
        #make check

# clean up apt
#RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG VERSION
ARG BUILD_DATE

