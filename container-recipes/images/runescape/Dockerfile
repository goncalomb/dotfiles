ARG RECIPE_HOST_DISPLAY
ARG RECIPE_HOST_ALSA
ARG RECIPE_HOST_GPU

FROM ubuntu:16.04

ARG RECIPE_HOST_GPU_DEBIAN_INSTALL
RUN sh -c "$RECIPE_HOST_GPU_DEBIAN_INSTALL"

WORKDIR root

RUN apt-get update
RUN apt-get install -y ca-certificates wget gnupg

# https://launchpad.net/ubuntu/trusty/amd64/libglew1.10/1.10.0-3
RUN apt-get install -y multiarch-support libgl1-mesa-glx
RUN wget http://launchpadlibrarian.net/161405671/libglew1.10_1.10.0-3_amd64.deb
RUN dpkg -i libglew1.10_1.10.0-3_amd64.deb

# https://www.runescape.com/download
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv AAC9264309E4D717441DB9527373B12CE03BEB4B
RUN echo "deb http://content.runescape.com/downloads/ubuntu trusty non-free" > /etc/apt/sources.list.d/runescape.list
RUN apt-get update
RUN apt-get install -y libcurl3 runescape-launcher

ENTRYPOINT runescape-launcher
