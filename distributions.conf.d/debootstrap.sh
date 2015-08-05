#!/bin/bash

# This script does the two stage bootstrapping with debootstrap
# Required environ variables:
#  $arch          target architecture, e.g. armhf
#  $packages      List of all packages to be installed
#  $deb_repos     Repositories from which to get the packages
#  $deb_release   Release of Debian to be bootstrapped
#  $deb_mirror    Mirror from which to download the packages
#  $rootfs        Target filesystem where the debian system should be bootsrapped

# Check if required variables are set

arch=${arch?Error arch is not defined.}
packages=${packages?Error packages is not defined.}
deb_repos=${deb_repos?Error deb_repos is not defined.}
deb_release=${deb_release?Error deb_release is not defined.}
deb_mirror=${deb_mirror?Error deb_mirror is not defined.}
rootfs=${rootfs?Error rootfs is not defined.}

packages=$(echo ${packages} | sed 's/ /,/g')

# first stage of bootstrapping
debootstrap \
    --foreign \
    --arch=armhf \
    --include=$packages \
    --variant=minbase \
    --components=$(echo $deb_repos | tr ' ' ',') \
    $deb_release \
    $rootfs \
    $deb_mirror \
|| exit 1

# copy static qemu for foreign architecture chroot
cp /usr/bin/qemu-arm-static $rootfs/usr/bin/

# second stage of bootstrapping
LANG=C chroot $rootfs /debootstrap/debootstrap --second-stage