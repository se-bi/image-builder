#!/bin/sh

rootfs=$1
cat << EOF > ${rootfs}/50_ros_kinetic.sh
#!/bin/bash

# For debugging purposes
set +x

# These linear scripts without error handling shall not continue when an error occurred.
set -e

#######################################################################################
# Install and configure ROS Kinetic
# Supported with Ubuntu 16.04 LTS only

# Add a non-root user for ROS
adduser --disabled-password --gecos "" ros
echo "ros:ros" | chpasswd

apt-get update
apt-get install -y lsb-release

# 1.2 Setup your sources.list
echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list

# 1.3 Set up your keys
apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-key 0xB01FA116

# 1.4 Installation
apt-get update
apt-get install -y ros-kinetic-desktop

# 1.5 Initialize rosdep
echo "source /opt/ros/kinetic/setup.bash" >> /home/ros/.bashrc
source /opt/ros/kinetic/setup.bash

# 1.6 Environment setup
rosdep init
su -c "rosdep update" ros

# 1.7 Getting rosinstall
apt-get install -y python-rosinstall

apt-get clean
# delete this script
rm -f \$0
EOF

chmod +x ${rootfs}/50_ros_kinetic.sh
LANG=C chroot $rootfs /50_ros_kinetic.sh
