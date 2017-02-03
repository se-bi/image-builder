#!/bin/sh

rootfs=$1

eval "sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' ${rootfs}/etc/ssh/sshd_config"
