#!/bin/bash

# Example of building a minimal booting image for RPi 2 Model B with Debian Wheezy.
# There a serial console with 115200 8N1 at UART0. Login is root:root

# Board
board=rpi-2-b

# Distribution
distribution=debian-wheezy

hostname="debug"
