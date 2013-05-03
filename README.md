# core-builder

core-builder is a tool for building root filesystems based on Ubuntu Core 
releases. The goal is to make it easy to configure and deploy minimal releases 
of Ubuntu Core.

Currently, core-builder only supports ARM targets. It has only been tested on a
Ubuntu 12.10 host.

## Requirements
core-builder requires build-essential and qemu-user-static to chroot into the root
filesystem.

    sudo apt-get install build-essential qemu-user-static

## Usage

core-builder is invoked using make. The available commands are:

  * make core - make a core filesystem (run this first)"
  * make packages - install all packages to the rootfs"
  * make chroot - chroot into rootfs"
  * make clean - delete ALL work"

The typical use case is to run `make core` to download and configure a rootfs,
then use `make packages` to install specified packages. You can use `make 
chroot` to enter the environment.

Currently, all commands must be run as root! This is required to mount the
filesystem and set up the chroot environment.

There is no automatic configuration at the moment. All configuration (Ubuntu 
release, packages, etc...) must be done in the Makefile.

## TODO

* Automatic configuration
* Automate more configuration
  * Hostname
  * Users / sudoers
  * Network
* Support for batch installing deb packages
* Support for building releases (tarballs, images, etc...)
* Support for booting in QEMU

## About

core-builder is by [Eric Evenchick](http://evenchick.com), and licensed under the
GPL.
