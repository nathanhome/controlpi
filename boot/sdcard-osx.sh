#!/bin/bash

###
# Headless image preparation for raspberry pis
# with WLAN configuration
# example call: 
#     ./sdcard-osx.sh ~/Downloads/2020-02-13-raspbian-buster-lite.img disk2
imagepath=$1
diskname=$2   # just the name, not the raw name, without /dev

sudo diskutil unmountDisk /dev/$2
sudo dd if=$imagepath of=/dev/r$2 bs=1m conv=sync
sleep 1
# I prefer a fixed line connection to my internet endpoint
# and wireless only for devices connected to it
#cp wpa_supplicant.conf /Volumes/boot
cp config.txt /Volumes/boot
touch /Volumes/boot/ssh
sudo diskutil unmountDisk /dev/$2
