#!/bin/bash

# Place commands that should run in the chrooted system here

# echo "# Remastered" >> /etc/os-release # Don't do this, it disturbs add-apt-repository

echo "In chroot: disabling apt ipv6..."
sudo bash -c "echo net.ipv6.conf.all.disable_ipv6=1 >> /etc/sysctl.conf"
sudo bash -c "echo net.ipv6.conf.default.disable_ipv6=1 >> /etc/sysctl.conf"

echo "In chroot: removing preinstalled apps & games..."
sudo apt-get autoremove --purge -f -q -y rhythmbox* remmina* totem* transmission* aisleriot* gnome-mahjongg* gnome-mines* gnome-sudoku* simple-scan* gnome-todo* baobab* deja-dup* gnome-calendar* example-content* usb-creator-gtk* thunderbird* mozc* geary* synaptic* libreoffice* gnome-logs gnome-system-log

echo "In chroot: adding smplayer ppa..."
sudo -E add-apt-repository -y ppa:rvm/smplayer

echo "In chroot: adding ffmpeg-4 ppa..."
sudo -E add-apt-repository -y ppa:jonathonf/ffmpeg-4

echo "In chroot: adding mpv ppa..."
sudo -E add-apt-repository -y ppa:mc3man/mpv-tests

echo "In chroot: adding cybermax's ppas..."
sudo -E add-apt-repository -y ppa:cybermax-dexter/vulkan-backports
sudo -E add-apt-repository -y ppa:cybermax-dexter/sdl2-backport

echo "In chroot: adding nvidia drivers ppa..."
sudo -E add-apt-repository -y ppa:graphics-drivers/ppa

echo "In chroot: installing winehq ppa + winehq..."
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo -E add-apt-repository -y 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
sudo rm winehq.key

echo "In chroot: apt upgrade..."
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade

echo "In chroot: apt smplayer..."
sudo apt-get -y install smplayer smplayer-themes

echo "In chroot: install nv drivers..."
sudo apt-get install -y nvidia-driver-430 libvulkan1:i386

echo "In chroot: install winehq-staging..."
sudo apt-get install -y --install-recommends winehq-staging

echo "In chroot: apt cleanup..."
sudo apt-get -y autoremove && sudo apt-get autoclean
