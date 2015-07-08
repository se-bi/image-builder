#!/bin/sh

# Configuring basic boot parameters.

rootfs=$1

# Configure GPU to only 16M as this RPi is used headless
echo "gpu_mem=16" >> ${rootfs}/boot/config.txt

echo "vchiq
" >> ${rootfs}/etc/modules
