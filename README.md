# About
This repository focuses on launching QEMU using Xilinx Petalinux inside docker. The basic steps can be found [here](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/821985321/Launching+QEMU+Using+Xilinx+PetaLinux#LaunchingQEMUUsingXilinxPetaLinux-DownloadandInstallPetaLinux). However, dockerizing the installation is the objective in this repo.

# Acknowledgement
The docker build script and dockerfile are sourced from another github repository: https://github.com/carlesfernandez/docker-petalinux2. They are reused with slight modifications, mainly using with ubuntu version 20.04, petalinux version 2024.1. Since the focus of this repository will be on using qemu, all the vivado installation related parts are removed.

# Instructions
This project is created in Ubuntu. But in order to use in Windows 10 or above, install Docker Desktop.

## Installation Prerequisites
Supported Ubuntu version for Petalinux 2024.1: from 20.04 and above (using 20.04 as the base image in Dockerfile). The docker image (excluding Vivado tools) would require space only up to around 13-15 GB in root directory. 

However, make sure that there is enough memory in root. Otherwise, repartition or extend memory in case of dual boot with Windows. There are several video tutorials available on YouTube.

Note:

* If Vivado tools are to be included, then the required space would go above 100 GB.
* The way how to automatically skip or acknowledge the licenses varies from version to version in petalinux, which requires an argument or a flag when running the installer script. Check the corresponding version's reference guide. Failing or getting stuck at this step leads to incomplete installation process; this issue will be evident if:

  - the installed docker size is only within a couple of GB, whereas the total size should be around 13-15 GB.
  - the following error/warning is seen when running the docker image (after installation): ```bash:/opt/xilinx/petalinux/settings.sh: no such file or directory```.

## Installation Process
Below are the steps that need to be done to successfully launch QEMU. The files can be downloaded [here](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html). Please note that AMD will ask for an account registration (free) to allow downloading the files.
1. Download Petalinx Tools Installer v2024.1.
2. Download ZCU102 BSP. Prebuilt Board Support Package for ZCU102 evaluation board based on Zynq Ultrascale+ MPSOC is used in this repo.
3. Place the downloaded files under libaries/qemu, or create a new directory and change the path in the corresponding lines in docker_build.sh and Dockerfile scripts.
4. Run docker_build.sh script. If there is any error during installation, refer to [Installation Prerequisites](#installation-prerequisites) subsection.

### Build docker
```
./docker_build.sh
```

## Launching QEMU
TODO: Work in progress...

### Run docker
```
docker run -it --rm --privileged \
  -h $(hostname) \
  -e DISPLAY=${DISPLAY} \
  --net=host \
  -v `pwd`:`pwd` \
  -w `pwd` \
  -u petalinux \
  petalinux:2024.1
```

# Additional info
Introduction to Petalinux can be found in this [link](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/embedded-software/petalinux-sdk.html#tools). For more details on installing the Petalinux, please visit their reference guide [here](https://docs.amd.com/r/en-US/ug1144-petalinux-tools-reference-guide/Overview).