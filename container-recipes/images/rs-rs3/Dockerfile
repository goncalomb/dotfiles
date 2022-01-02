ARG RECIPE_REUSE_CONTAINER
ARG RECIPE_HOST_DISPLAY
ARG RECIPE_HOST_ALSA
ARG RECIPE_HOST_GPU

FROM ubuntu:20.04

ARG RECIPE_HOST_GPU_DEBIAN_INSTALL
RUN sh -c "$RECIPE_HOST_GPU_DEBIAN_INSTALL"

WORKDIR root

RUN apt-get update
RUN apt-get install -y gnupg

# https://www.runescape.com/download
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv AAC9264309E4D717441DB9527373B12CE03BEB4B
RUN echo "deb http://content.runescape.com/downloads/ubuntu trusty non-free" > /etc/apt/sources.list.d/runescape.list
RUN apt-get update
RUN apt-get install -y runescape-launcher

ENTRYPOINT runescape-launcher
