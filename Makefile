VERSION = 1.0

# if the config.mk file exists, include it. otherwise, use these defaults
-include config.mk

############################################################
# Defaults
############################################################

# UBUNTU_RELEASE: year.month of ubuntu core relase to use
UBUNTU_RELEASE ?= 11.10
# ROOTFS_DIR: directory to build root filesystem in
ROOTFS_DIR ?= rootfs
# NAMESERVER: nameserver to populate rootfs with (default is Google's 8.8.8.8)
NAMESERVER ?= 8.8.8.8

############################################################
# Binaries
############################################################

MKDIR ?= mkdir
DD ?= dd
MKFS ?= mkfs.ext3
RM ?= rm
CP ?= cp
ECHO ?= echo
QEMU_ARM_STATIC ?= `which qemu-arm-static`
APT_GET ?= apt-get
CHROOT ?= chroot
WGET ?= wget

# CORE_TARBALL: tarball containing core filesystem
CORE_TARBALL = ubuntu-core-$(UBUNTU_RELEASE)-core-armel.tar.gz
CORE_TARBALL_URL = http://cdimage.ubuntu.com/ubuntu-core/releases/$(UBUNTU_RELEASE)/release/$(CORE_TARBALL)

# helper to run commands in chroot
CHROOT_EXEC = $(CHROOT) $(ROOTFS_DIR)

# helper to set up chroot
CHROOT_UP = mount -t proc /proc $(ROOTFS_DIR)/proc; mount -t sysfs /sys $(ROOTFS_DIR)/sys/; mount -o bind /dev $(ROOTFS_DIR)/dev/

# helper to clean up chroot
CHROOT_DOWN = umount $(ROOTFS_DIR)/proc/; umount $(ROOTFS_DIR)/sys/; umount $(ROOTFS_DIR)/dev/

# colors
NO_COLOR = \033[0m
INFO_COLOR = \033[32;01m

INFO_STRING = [$(INFO_COLOR)INFO$(NO_COLOR)]

help:
	@echo "core-builder v$(VERSION)\n"
	@echo "core-builder is used to build root filesystems based on Ubuntu Core releases."
	@echo "For more information, see the README file.\n"
	@echo "Commands:"
	@echo "make core\tmake a core filesystem (run this first)"
	@echo "make packages\tinstall all packages to the rootfs"
	@echo "make chroot\tchroot into rootfs"
	@echo "make clean\tdelete ALL work"
	@echo "\nNote: all commands must be run with root permissions!"

# all
# make the core system (even if it's built) then install all packages
all: core packages

# chroot
# setup and enter chroot environment
chroot: $(ROOTFS_DIR)
	@echo "$(INFO_STRING) setting up chroot..."
	$(CHROOT_UP)
	@echo "$(INFO_STRING) entering chroot..."
	-$(CHROOT) $(ROOTFS_DIR)
	@echo "$(INFO_STRING) cleaning up chroot..."
	$(CHROOT_DOWN)
	@echo "$(INFO_STRING) done."

# packages
# install all packages

packages: apt-packages

# apt-packages
# install packages specified by APT_PACKAGES using apt-get on target

apt-packages: $(ROOTFS_DIR)
	@echo "$(INFO_STRING) installing packages using APT..."
	@echo "$(INFO_STRING) setting up chroot..."
	$(CHROOT_UP)
	@echo "$(INFO_STRING) doing apt-get update..."
	$(CHROOT_EXEC) $(APT_GET) update
	@echo "$(INFO_STRING) installing packages..."
	$(CHROOT_EXEC) $(APT_GET) -y install $(APT_PACKAGES)
	@echo "$(INFO_STRING) cleaning up chroot..."
	$(CHROOT_DOWN)
	@echo "$(INFO_STRING) APT packages installed successfully!"

# core
# set up the core system, using the following steps:
# extract the core tarball
# set up resolv.conf with a valid nameserver
# copy qemu-arm-static to allow binaries to run on a non-arm system
	
core: | $(ROOTFS_DIR) $(CORE_TARBALL)
	@echo "$(INFO_STRING) building base system..."
	@echo "$(INFO_STRING) extracting tarball ($(CORE_TARBALL))..."
	tar -C $(ROOTFS_DIR) -xzf $(CORE_TARBALL)
	@echo "$(INFO_STRING) creating resolv.conf using namserver $(NAMESERVER)..."
	$(ECHO) "nameserver $(NAMESERVER)" > $(ROOTFS_DIR)/etc/resolv.conf
	@echo "$(INFO_STRING) setting up qemu..."
	$(CP) $(QEMU_ARM_STATIC) $(ROOTFS_DIR)/usr/bin
	@echo "$(INFO_STRING) done."

# clean
# clean up
clean:
	-rm -rf $(ROOTFS_DIR)

.PHONY: clean core packages apt-packages

# create the directory to build root filesystem in
$(ROOTFS_DIR):
	-$(MKDIR) $@

# fetch the core rootfs tarball
$(CORE_TARBALL):
	$(WGET) $(CORE_TARBALL_URL)
