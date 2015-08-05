#!/bin/sh

rootfs=$1

echo "auto lo
iface lo inet loopback
" > ${rootfs}/etc/network/interfaces
