#!/bin/bash

# Place commands that should run in the chrooted system here

# echo "# Remastered" >> /etc/os-release # Don't do this, it disturbs add-apt-repository

echo "In chroot: disabling apt ipv6..."
sudo bash -c "echo 'Acquire::ForceIPv4 \"true\";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4"

echo "In chroot: removing preinstalled apps & games..."
sudo apt-get autoremove --purge -f -q -y rhythmbox* remmina* totem* transmission* aisleriot* gnome-mahjongg* gnome-mines* gnome-sudoku* simple-scan* gnome-todo* baobab* deja-dup* gnome-calendar* example-content* usb-creator-gtk* thunderbird* mozc* geary* synaptic* gnome-logs gnome-system-log

echo "In chroot: adding smplayer ppa..."
sudo -E add-apt-repository -y ppa:rvm/smplayer

echo "In chroot: adding mpv ppa..."
sudo -E add-apt-repository -y ppa:mc3man/mpv-tests

echo "In chroot: apt upgrade..."
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade

echo "In chroot: apt smplayer..."
sudo apt-get -y install smplayer smplayer-themes

echo "In chroot: apt cleanup..."
sudo apt-get -y autoremove && sudo apt-get autoclean
