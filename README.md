[![Build Status](https://travis-ci.org/strongly-typed/image-builder.svg?branch=master)](https://travis-ci.org/strongly-typed/image-builder)

# image-builder

Build custom Linux images for embedded Linux boards.

These set of scripts intend to build custom Linux images from scratch for
embedded Linux boards with ARM processors, like

	* Raspberry Pi Model B
	* Raspberry Pi 2 Model B
	* Phytec phyBOARD Wega
	* Hardkernel Odroid U3
	* Beaglebone Black

Based on work by Klaus M Pfeiffer at 
http://blog.kmp.or.at/2012/05/build-your-own-raspberry-pi-image/
and further work by [Daniel Krebs](https://github.com/daniel-k) from 
[Roboterclub Aachen](http://www.roboterclub.rwth-aachen.de/)

Main development target as of now is the Raspberry Pi 2 Model B.

# Organisation of directories

* `boards.conf.d` includes subdirectories for different hardware platforms and
  the corresponding kernel and/or firmeware installation methods.

* `distributions.conf.d` includes subdirectories for different Linux 
  distributions, mainly Debian and Ubuntu.

* `applications.conf.d` holds files for various applications that can be added
  to the distributions.

* `systems.conf.d` uses a combination of a board, a distribution and 
  one or more applications to build a specific image for a specific purpose

* `build.d` holds the created images for deployment.

# Usage

Build a specific image by using

	sudo bootstrap.sh example-rpi-2-b-ubuntu-trusty-minimal

This will build a minimal bootable image for the Raspberry Pi 2 Model B with
Ubuntu Trusty Tahr. The resulting image will be located in the `build` folder.

Write this image to a SD card using `dd` and then boot the RPi.
There is only a serial console at UART0 with 115200 8N1. Login is root:root

Root access is required for the `bootstrap.sh` scrip doing all the loop device
and mount/umount commands.
