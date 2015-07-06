#!/bin/bash

# Check for root priviledges
#
#  return:  1 if user is not root
check_root ()
{
    if [ $EUID -ne 0 ]; then
      echo "ERROR: You are not root"
      return 1
    fi
}

# Check for the requirements to run all scripts
#
#  return:  1 if one ore more packages are missing
check_requirements ()
{
    req=( "kpartx" "qemu-arm-static" "debootstrap" "lvm" "dosfsck")

    for r in ${req[@]}; do
        command -v ${r} > /dev/null 2>&1 ||
        {
            echo "I require ${r}, but did not find it. Aborting" >&2
            exit 1
        }
    done
}

# Mount a SD-Card image as loopback device
#
#  $1: path to image file
#
#  return:  the loopback device, append 'pX'
#            access to patition X
loop_mount_image ()
{
    file=$1

    check_root || return 1

    if [ ! -f "$file" ]; then
        return 1
    fi
    
    device=`kpartx -va $file | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`

    echo $device
}


get_loopback_device ()
{
    file=$1
    
    check_root || return 1

    if [ ! -f "$file" ]; then
        return 1
    fi
    
    device=`losetup -a | grep $file | head -n 1 | cut -d':' -f1 | cut -d'/' -f3`
    
    echo $device
}

# Unmount SD-Card image
#
#  $1: path to image file
loop_unmount_image ()
{
    file=$1

    if [ ! -f "$file" ]; then
        return 1
    fi
    
    kpartx -d $file
    
    # sometimes kpartx fails to remove the mappings
    device=$(get_loopback_device $file)
    #echo "### got device $device"
    for partition in `dmsetup info | grep ${device}p | awk '{print $2}'`
    do
        #echo "### remove mapping $partition"
        dmsetup remove $partition
    done
    
    # and remove loopback device
    losetup -d /dev/$device
}

# Mount a SD-Card image and it's partitions to
# a mountpoint.
#
#  $1: path to image file
#  $2: mountpoint
mount_image ()
{    
    file=$1
    mntpoint=$2

    check_root || return 1

    if [ ! -f "$file" ] || [ ! -d "$mntpoint" ]; then
        return 1
    fi
    
    # check if loopback is already mounted
    device="$(get_loopback_device $file)"
    
    # mount if not
    if [ -z "$device" ]
    then
        device=$(loop_mount_image $file)
    fi
    
    # add full path
    device="/dev/mapper/$device"
    
    # now mount partitions on mountpoint
    mount ${device}p2 $mntpoint
    
    mkdir -p $mntpoint/boot
    mkdir -p $mntpoint/dev
    mkdir -p $mntpoint/proc

    mount ${device}p1 $mntpoint/boot
}

# Mount a SD-Card image as loopback device
#
#  $1: path to image file
#
#  return:  the loopback device, append 'pX'
#            access to patition X
unmount_image ()
{    
    file=$1

    check_root || return 1
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    device="/dev/mapper/$(get_loopback_device $file)"
    
    # make sure all writes are finished
    sync; sync; sync
    
    # kill every process that still accesses the mountpoints
    for dir in `mount | grep $device | cut -d' ' -f3`
    do
        fuser -k $dir
    done
    
    # unmount boot partition first
    umount -l ${device}p1
    sync; sleep 1; sync
    umount -l ${device}p2
    
    loop_unmount_image $file
}

# Boot partition has fixed size of 32MB and offset of 3072
create_image ()
{    
    file=${1?file not provided.}
    img_size=${2?img_size not provided.}
    img_partition_layout=${3?img_partition_layout not provided}

    # Check if file exist
    if [ ! -e ${img_partition_layout} ]; then
        echo "${img_partition_layout} does not exist."
        return 1
    fi

    check_root || return 1
    
    # don't overwrite existing image
    if [ -f "$file" ]; then
        return 1
    fi
        
    # create sparse image file
    touch "$file" || return 1
    dd if=/dev/zero of="$file" bs=1MB count=1 seek=$img_size

    # map image using losetup
    device="$(losetup -f --show $file)"

    # partition image
    # 32 MiB boot partition and
    # big root partition
    sfdisk $device -uM < ${img_partition_layout}

    sync; sync; sync

    # tidy up
    losetup -d $device

    # mount image again with partition mapping
    device="/dev/mapper/$(loop_mount_image $file)"

    mkfs.vfat -n BOOT ${device}p1
    mkfs.ext4 -L root ${device}p2

    sync; sync; sync

    # and tidy up again
    loop_unmount_image $file
}
