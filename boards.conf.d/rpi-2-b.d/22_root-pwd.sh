#!/bin/sh

# Setting the root password to root:root

rootfs=$1

echo "#!/bin/bash

# set root password
echo 'root:root' | chpasswd

# delete this script
rm -f \$0
" > ${rootfs}/root-pw
chmod +x ${rootfs}/root-pw
LANG=C chroot $rootfs /root-pw
