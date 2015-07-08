#!/bin/bash

# More debugging
set -x

boards_confd=${0%/*}/boards.conf.d
distributions_confd=${0%/*}/distributions.conf.d
systems_confd=${0%/*}/systems.conf.d
tools_d=${0%/*}/tools.d

source ${tools_d}/functions.sh

# Root privileges are needed
check_root || exit 1

# Check for requirements
check_requirements || exit 1

# Load configuration for this system
source ${systems_confd}/${1}.d/bootstrap.sh

# Get board configuration
board=${board?Board not provided}
source ${boards_confd}/${board}.d/${board}.conf

# Get distribution configuration
distribution=${distribution?Distribution not provided.}
source ${distributions_confd}/${distribution}.d/${distribution}.conf

echo "***************************************************************************"
echo " Building for board=${board} "
echo " Building with distribution=${distribution} "
echo "***************************************************************************"


################################# Directories ##################################

buildenv="$(readlink -f ${0%/*}/build)"

rootfs="${buildenv}/rootfs"
bootfs="${rootfs}/boot"

mydate=`date +%Y-%m-%d_%H%M`

# path to final image
image="${buildenv}/${hostname}_${deb_release}_${mydate}.img"


################################# Packages #####################################

# if not provided by config file
if [ -z "$packages" ]; then
    packages=""
fi

# packages+="ntp,ntpdate,openssh-server,"

# convenience and/or needed for using some tools interactively
packages+="dialog,less,nano,bzip2,"

# convenience
# packages+="bash-completion,htop,usbutils,picocom,mc,ack-grep,"

# localization and keyboard layout
# packages+="console-common,locales,"

# needed for rpi-update bootstrap
packages+="git-core,wget,curl,ca-certificates,binutils,"

# packages needed for networking
# packages+="net-tools,netbase,ifupdown,net-tools,isc-dhcp-client,"
# packages+="wireless-tools,wpasupplicant,inetutils-ping,"

# python and pyserial for serial to tcp redirect
# packages+="python,python-serial," #,python-pip,python-dev,build-essential"

# needed for openocd
# packages+="libusb-1.0-0"


############################## Image Handling ##################################

# make sure buildenv directory exists
mkdir -p $buildenv

# create image
echo " # creating image file '$(basename $image)' with size ${img_size}M and layout ${img_partition_layout}."
create_image $image $img_size $img_partition_layout || (echo "FAILED"; exit 1)

# make sure rootfs path exists
mkdir -p $rootfs

# mount image file to rootfs (mounts / and /boot)
mount_image $image $rootfs

# make sure /dev and /proc exist
mkdir -p $rootfs/dev
mkdir -p $rootfs/proc

mount -o bind /dev $rootfs/dev
mount -o bind /proc $rootfs/proc


############################### Bootstrapping ##################################

# First and second stage bootstrapping of Debian system
source ${distributions_confd}/debootstrap.sh


############################### Debian Setup ###################################

# set repository
echo "deb $deb_mirror $deb_release $deb_repos
" > $rootfs/etc/apt/sources.list

# create fstab
echo "proc            /proc           proc    defaults        0       0
/dev/mmcblk0p1  /boot           vfat    defaults        0       0
/dev/mmcblk0p2  /               ext4    defaults        0       0
" > $rootfs/etc/fstab

# configure hostname
echo "$hostname" > $rootfs/etc/hostname

# configure hostname in /etc/hosts
# @TODO

# TODO: this should be moved to config file
# kernel commandline for boot
echo "dwc_otg.lpm_enable=0 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 earlyprintk=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait" > $rootfs/boot/cmdline.txt


############################## conf.d scripts ##################################

export LANG=C
export LC_CTYPE=C
export LC_MESSAGES=C
export LC_ALL=C

# Run scripts from board directory
for script in ${boards_confd}/${board}.d/*.sh
do
    if [ ! -x "${script}" ]; then
        continue
    fi

    echo "Running script '${script}' in directory '${rootfs}'"
    ${script} "${rootfs}"
done

echo "Finished scripts from ${board_confd}"

# Run scripts from distribution directory
for script in ${distributions_confd}/${distribution}.d/*.sh
do
    if [ ! -x "${script}" ]; then
        continue
    fi
    echo "Running script '${script}' in directory '${rootfs}'"
    ${script} "${rootfs}"
done

echo "Finished scripts from ${distributions_confd}"

# board specific configuration scripts
# if [ -n "$board_confd" ] && [ -d "$confd/$board_confd" ]
# then
#    for script in $confd/$board_confd/*.sh
#    do
#        if [ ! -x "${script}" ]; then
#            continue
#        fi
#
#        echo "Running script '${script}' in directory '${rootfs}'"
#        ${script} "${rootfs}"
#    done
#fi


################################ Cleanup #######################################

# safety first
sync; sleep 1

umount -l $rootfs/dev
umount -l $rootfs/proc

# this does all the heavy lifting
unmount_image $image

# change ownership of buildenv to top folder
owner="$(namei -o ${buildenv}/.. | tail -n 1 | cut -d ' ' -f 3)"
group="$(namei -o ${buildenv}/.. | tail -n 1 | cut -d ' ' -f 4)"
chown -R $owner:$group $buildenv

echo "Created Image: $(basename $image)"
echo "Done."
