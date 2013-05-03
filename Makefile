VERSION = 1.0

# UBUNTU_RELEASE: year.month of ubuntu core relase to use
UBUNTU_RELEASE ?= 11.10

# FS_TYPE: type of filesystem to build. selects rootfs file extension and mkfs
# command
FS_TYPE ?= ext3
# ROOTFS_FILE: file to store root filesystem in
ROOTFS_FILE ?= rootfs.$(FS_TYPE)
# ROOTFS_SIZE_MB: desired size of the rootfs file, in MB
ROOTFS_SIZE_MB ?= 500
# MNT_DIR: directory to mount root filesystem to
MNT_DIR ?= rootfs

# NAMESERVER: nameserver to populate rootfs with (default is Google's 8.8.8.8)
NAMESERVER ?= 8.8.8.8

# APT_PACKAGES: a list of APT packages to install to the rootfs
APT_PACKAGES ?= net-tools


# Binaries
MKDIR ?= mkdir
MOUNT ?= mount
UMOUNT ?= umount
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

help:
	@echo "core-builder v$(VERSION)\n"
	@echo "core-builder is used to build root filesystems based on Ubuntu Core releases."
	@echo "For more information, see the README file.\n"
	@echo "Commands:"
	@echo "make packages\tinstall all packages to the rootfs"
	@echo "make core\tmake and mount a core filesystem"
	@echo "make mount\tmount a core filesystem"
	@echo "make unmount\tunmount a core filesystem"
	@echo "make clean\tdelete ALL work"
	@echo "\nNote: all commands must be run with root permissions!"

# all
# make the core system (even if it's built) then install all packages
all: core packages

# packages
# install all packages

packages: apt-packages

# apt-packages
# install packages specified by APT_PACKAGES using apt-get on target

apt-packages: $(MNT_DIR)
	@echo "Installing packages using APT..."
	$(CHROOT) $(MNT_DIR) 			\
	$(APT_GET) update; 			\
	$(APT_GET) -y install $(APT_PACKAGES);	\

# core
# set up the core system, using the following steps:
# extract the core tarball
# set up resolv.conf with a valid nameserver
# copy qemu-arm-static to allow binaries to run on a non-arm system
# chroot into rootfs
# update apt lists
# install specified packages
# leave the environment
	
core: | $(ROOTFS_FILE) $(MNT_DIR) $(CORE_TARBALL)
	@echo "Building base system..."
	tar -C $(MNT_DIR) -xzf $(CORE_TARBALL)
	$(ECHO) "nameserver $(NAMESERVER)" > $(MNT_DIR)/etc/resolv.conf
	$(CP) $(QEMU_ARM_STATIC) $(MNT_DIR)/usr/bin

# mount
# mount the rootfs filesystem file
mount: $(MNT_DIR)

# unmount
# unmount the rootfs filesystem file
unmount:
	-$(UMOUNT) $(MNT_DIR)
	-$(RM) -rf $(MNT_DIR)

# clean
# clean up
clean: unmount
	-rm $(ROOTFS_FILE)
	-rm $(CORE_TARBALL)

.PHONY: mount clean unmount core packages apt-packages

# create the directory to mount into
$(MNT_DIR): | $(ROOTFS_FILE)
	-$(MKDIR) $@	
	$(MOUNT) -o loop $(ROOTFS_FILE) $(MNT_DIR)

# create the empty rootfs file, creating a file system in it
$(ROOTFS_FILE):
	$(DD) if=/dev/zero of=$@ bs=1M count=$(ROOTFS_SIZE_MB)	
	$(MKFS) -F $@

# fetch the core rootfs tarball
$(CORE_TARBALL):
	$(WGET) $(CORE_TARBALL_URL)
