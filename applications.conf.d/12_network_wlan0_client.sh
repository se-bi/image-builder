#!/bin/sh

rootfs=$1

echo "allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-ssid \"myssid\"
    wpa-psk \"myPassword\"
" >> ${rootfs}/etc/network/interfaces
