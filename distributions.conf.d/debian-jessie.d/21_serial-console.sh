#!/bin/sh

rootfs=$1

serial_port="ttyAMA0"
serial_baudrate="115200"

eval "sed -i 's/# The default runlevel./# Create login shell as soon as possible so that\n# login is possible even if a init.d script hangs\nT0:23:respawn:\/sbin\/getty -L ${serial_port} ${serial_baudrate} vt100\n\n# The default runlevel./' ${rootfs}/etc/inittab"
