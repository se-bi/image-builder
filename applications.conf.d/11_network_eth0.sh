#!/bin/sh

rootfs=$1

echo "auto eth0
iface eth0 inet static
    address 192.168.10.1
    netmask 255.255.255.0
" >> ${rootfs}/etc/network/interfaces
