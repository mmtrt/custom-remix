#!/bin/bash

# Place commands that should run in the chrooted system here

# echo "# Remastered" >> /etc/os-release # Don't do this, it disturbs add-apt-repository

echo "In chroot: disabling apt ipv6..."
sudo bash -c "echo 'Acquire::ForceIPv4 \"true\";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4"

echo "In chroot: removing preinstalled apps & games..."
sudo apt-get autoremove --purge -f -q -y rhythmbox* remmina* totem* transmission* aisleriot* gnome-mahjongg* gnome-mines* gnome-sudoku* simple-scan* gnome-todo* baobab* deja-dup* gnome-calendar* example-content* usb-creator-gtk* thunderbird* mozc* geary* synaptic* libreoffice* gnome-logs gnome-system-log

echo "In chroot: adding smplayer ppa..."
sudo -E add-apt-repository -y ppa:rvm/smplayer

echo "In chroot: adding ffmpeg-4 ppa..."
sudo -E add-apt-repository -y ppa:jonathonf/ffmpeg-4

echo "In chroot: adding mpv ppa..."
sudo -E add-apt-repository -y ppa:mc3man/mpv-tests

echo "In chroot: adding cybermax ppa..."
sudo -E add-apt-repository -y ppa:cybermax-dexter/sdl2-backport

echo "In chroot: adding own ppa..."
sudo -E add-apt-repository -y ppa:mmtrt/testing

echo "In chroot: installing winehq ppa + winehq..."
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo -E add-apt-repository -y 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
sudo rm winehq.key

echo "In chroot: apt upgrade..."
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade

echo "In chroot: apt smplayer..."
sudo apt-get -y install smplayer smplayer-themes

echo "In chroot: install nv deps..."
sudo apt-get install -y build-essential dkms dpkg-dev fakeroot g++ g++-7 gcc gcc-7 gcc-8-base:i386 libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libasan4 libatomic1 libatomic1:i386 libbsd0:i386 libc-dev-bin libc6:i386 libc6-dev libcilkrts5 libdrm-amdgpu1:i386 libdrm-intel1:i386 libdrm-nouveau2:i386 libdrm-radeon1:i386 libdrm2:i386 libedit2:i386 libelf1:i386 libexpat1:i386 libfakeroot libffi6:i386 libgcc-7-dev libgcc1:i386 libgl1:i386 libgl1-mesa-dri:i386 libglapi-mesa:i386 libglvnd0:i386 libglx-mesa0:i386 libglx0:i386 libitm1 libllvm8:i386 liblsan0 libmpx2 libpciaccess0:i386 libquadmath0 libsensors4:i386 libstdc++-7-dev libstdc++6:i386 libtinfo5:i386 libtsan0 libubsan0 libvulkan1:i386 libx11-6:i386 libx11-xcb1:i386 libxau6:i386 libxcb-dri2-0:i386 libxcb-dri3-0:i386 libxcb-glx0:i386 libxcb-present0:i386 libxcb-sync1:i386 libxcb1:i386 libxdamage1:i386 libxdmcp6:i386 libxext6:i386 libxfixes3:i386 libxnvctrl0 libxshmfence1:i386 libxxf86vm1:i386 linux-libc-dev make manpages-dev nvidia-settings pkg-config screen-resolution-extra zlib1g:i386

echo "In chroot: manually downloading nv driver debs..."
DVER="418.52.20-0~bionic1"
for dl in libnvidia-cfg1-418_${DVER}_amd64.deb libnvidia-common-418_${DVER}_all.deb libnvidia-compute-418_${DVER}_amd64.deb libnvidia-compute-418_${DVER}_i386.deb libnvidia-decode-418_${DVER}_amd64.deb libnvidia-decode-418_${DVER}_i386.deb libnvidia-encode-418_${DVER}_amd64.deb libnvidia-encode-418_${DVER}_i386.deb libnvidia-fbc1-418_${DVER}_amd64.deb libnvidia-fbc1-418_${DVER}_i386.deb libnvidia-gl-418_${DVER}_amd64.deb libnvidia-gl-418_${DVER}_i386.deb libnvidia-ifr1-418_${DVER}_amd64.deb libnvidia-ifr1-418_${DVER}_i386.deb nvidia-compute-utils-418_${DVER}_amd64.deb nvidia-dkms-418_${DVER}_amd64.deb nvidia-driver-418_${DVER}_amd64.deb nvidia-kernel-common-418_${DVER}_amd64.deb nvidia-kernel-source-418_${DVER}_amd64.deb nvidia-utils-418_${DVER}_amd64.deb xserver-xorg-video-nvidia-418_${DVER}_amd64.deb; do wget https://launchpad.net/~mmtrt/+archive/ubuntu/testing/+files/${dl} ; done

echo "In chroot: manually installing nv driver debs..."
sudo dpkg -i *.deb && rm `ls | grep ".deb"`


echo "In chroot: holding pkgs to not update nv driver debs..."
sudo apt-mark hold libnvidia-cfg1-418 libnvidia-common-418 libnvidia-compute-418 libnvidia-compute-418:i386 libnvidia-decode-418 libnvidia-decode-418:i386 libnvidia-encode-418 libnvidia-encode-418:i386 libnvidia-fbc1-418 libnvidia-fbc1-418:i386 libnvidia-gl-418 libnvidia-gl-418:i386 libnvidia-ifr1-418  libnvidia-ifr1-418:i386 nvidia-compute-utils-418 nvidia-dkms-418 nvidia-driver-418 nvidia-kernel-common-418 nvidia-kernel-source-418 nvidia-utils-418 xserver-xorg-video-nvidia-418

echo "In chroot: install winehq-staging..."
sudo apt-get install -y --install-recommends winehq-staging

echo "In chroot: apt cleanup..."
sudo apt-get -y autoremove && sudo apt-get autoclean
