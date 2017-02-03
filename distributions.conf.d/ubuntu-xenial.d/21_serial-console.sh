#!/bin/sh

# Adding a serial debug terminal to upstart.

# serial_device="ttyAMA0"

rootfs=$1

files="$(readlink -f ${0%/*}/files/)"

file="${files}/ttyAMA0.conf"

cp ${file} ${rootfs}/etc/init/
