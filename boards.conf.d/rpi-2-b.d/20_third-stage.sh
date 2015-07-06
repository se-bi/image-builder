#!/bin/sh

# Conducting third stage of bootstrapping. Install binary firmware and kernel.

rootfs=$1

echo "#!/bin/bash

# get rpi-update and install firmware and tools
# Without this, RPi does not boot at all
wget https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update
chmod +x /usr/bin/rpi-update
touch /boot/start.elf

# update firmware and tools and skip warning about new kernel version
SKIP_WARNING=1 rpi-update

sed -i -e 's/KERNEL\!=\"eth\*|/KERNEL\!=\"/' /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules

# add /opt/vc tools to system path. These tools were installed by rpi-update
echo 'export PATH=/opt/vc/bin:/opt/vc/sbin/:\$PATH' > /etc/profile.d/vc.sh
echo '/opt/vc/lib' > /etc/ld.so.conf.d/vc.conf
ldconfig

# delete this script
rm -f \$0
" > ${rootfs}/third-stage
chmod +x ${rootfs}/third-stage
LANG=C chroot $rootfs /third-stage
