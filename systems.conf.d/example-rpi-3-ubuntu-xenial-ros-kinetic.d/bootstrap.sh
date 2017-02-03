#!/bin/bash

# Example of building a minimal booting image for RPi 2 Model B with Ubuntu Trusty.
# There a serial console with 115200 8N1 at UART0. Login is root:root

# Board
board="rpi-2-b"

# Distribution
distribution="ubuntu-xenial"

# Applications
applications=("10_network_local" "11_network_eth0" "50_ros_kinetic")

hostname="debug"
