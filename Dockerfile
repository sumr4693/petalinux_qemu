# SPDX-FileCopyrightText: 2021-2023, Carles Fernandez-Prades <carles.fernandez@cttc.es>
# SPDX-License-Identifier: MIT

# Acknowledgement:
# Source of this file can be found in https://github.com/carlesfernandez/docker-petalinux2. Reused with minor modifications.

# Main updates:
# Using ubuntu 20.04, petalinux version 2024.1, removing Vivado related parts.

FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
  autoconf \
  automake \
  bc \
  bison \
  build-essential \
  ca-certificates \
  chrpath \
  cpio \
  curl \
  dbus \
  dbus-x11 \
  debianutils \
  diffstat \
  expect \
  flex \
  fonts-droid-fallback \
  fonts-ubuntu-font-family-console \
  gawk \
  gcc-multilib \
  git \
  git-core \
  gnupg \
  gtk2-engines \
  gzip \
  iproute2 \
  iputils-ping \
  kmod \
  lib32z1-dev \
  libbz2-dev \
  libcanberra-gtk-module \
  libegl1-mesa \
  libffi-dev \
  libgdbm-dev \
  libglib2.0-dev \
  libgtk2.0-0 \
  libjpeg62-dev \
  libpython3.8-dev \
  libncurses5-dev \
  libnss3-dev \
  libreadline-dev \
  libsdl1.2-dev \
  libselinux1 \
  libsqlite3-dev \
  libssl-dev \
  libswt-gtk-4-jni \
  libtool \
  libtool-bin \
  locales \
  lsb-release \
  lxappearance \
  make \
  nano \
  net-tools \
  pax \
  pkg-config \
  pylint3 \
  python \
  python3 \
  python3-pexpect \
  python3-pip \
  python3-git \
  python3-jinja2 \
  rsync \
  screen \
  socat \
  sudo \
  tar \
  texinfo \
  tftpd \
  tofrodos \
  ttf-ubuntu-font-family \
  u-boot-tools \
  ubuntu-gnome-default-settings \
  unzip \
  update-inetd \
  wget \
  xorg \
  xterm \
  xvfb \
  xxd \
  xz-utils \
  zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install GitPython jinja2

RUN dpkg --add-architecture i386 && apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
  zlib1g:i386 libc6-dev:i386 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Petalinux requires bash (instead of dash which is default in Ubuntu)
RUN ln -fs /bin/bash /bin/sh

RUN locale-gen en_US.UTF-8 && update-locale

# Build and install Python 3.11, required by repo
RUN wget https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tgz \
  && tar -xf Python-3.11.*.tgz && cd Python-3.11.*/ \
  && ./configure --enable-optimizations && make && make altinstall \
  && cd .. && rm Python-3.11.*.tgz && rm -rf Python-3.11.*/

# Make a petalinux user
RUN adduser --disabled-password --gecos '' petalinux && \
  usermod -aG sudo petalinux && \
  echo "petalinux ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install the repo tool to handle git submodules (meta layers) comfortably.
ADD https://storage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 777 /usr/local/bin/repo

ARG PETA_VERSION
ARG PETA_RUN_FILE

# The HTTP server to retrieve the files from.
ARG HTTP_SERV=http://172.17.0.1:8000/libraries/qemu

# Run the Petalinux installer, skip license
RUN cd / && wget -q ${HTTP_SERV}/${PETA_RUN_FILE} && \
  chmod a+rx /${PETA_RUN_FILE} && \
  mkdir -p /opt/Xilinx/petalinux && \
  chmod 777 /tmp /opt/Xilinx/petalinux && \
  cd /tmp && \
  /${PETA_RUN_FILE} -y --dir /opt/Xilinx/petalinux && \
  rm -f /${PETA_RUN_FILE}

# not really necessary, just to make it easier to install packages on the run...
RUN echo "root:petalinux" | chpasswd

USER petalinux
ENV HOME /home/petalinux
ENV LANG en_US.UTF-8
RUN mkdir /home/petalinux/project
WORKDIR /home/petalinux/project
ENV SHELL /bin/bash

# Source settings at login
USER root
RUN echo "/usr/sbin/in.tftpd --foreground --listen --address [::]:69 --secure /tftpboot" >> /etc/profile && \
  echo ". /opt/Xilinx/petalinux/settings.sh" >> /etc/profile && \
  echo ". /etc/profile" >> /root/.profile

EXPOSE 69/udp

USER petalinux

ENTRYPOINT ["/bin/bash", "-l"]