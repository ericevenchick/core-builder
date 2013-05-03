# core-builder

core-builder is a tool for building root filesystems based on Ubuntu Core releases.  
The goal is to make it easy to configure and deploy minimal releases of Ubuntu 
Core.

Currently, core-builder only supports ARM targets. It has only been tested on a
Ubuntu 12.10 host.

## Requirements
core-builder requires build-essential and qemu-user-static to chroot into the root
filesystem.

    sudo apt-get install build-essential qemu-user-static

## Usage

core-builder is invoked using make. The available commands are:

* make packages - install specified packages to the root filesystem
* make core - set up an ARM Ubuntu Core root filesystem
* make mount - mount the root filesystem to a directory
* make unmount - unmount the root filesystem
* make clean - delete **all** work in progress

The typical use case is to run `make core` to download and configure a rootfs,
then use `make packages` to install specified packages. You can also run `chroot
rootfs` as root to chroot into the root filesystem.

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
* Support for building packages from source

## About

core-builder is by [Eric Evenchick](http://evenchick.com), and licensed under the
GPL.
