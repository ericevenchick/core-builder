# UBUNTU_RELEASE: year.month of ubuntu core relase to use
UBUNTU_RELEASE ?= 11.10

# ROOTFS_DIR: directory to build root filesystem in
ROOTFS_DIR ?= rootfs

# NAMESERVER: nameserver to populate rootfs with (default is Google's 8.8.8.8)
NAMESERVER ?= 8.8.8.8

# APT_PACKAGES: a list of APT packages to install to the rootfs
APT_PACKAGES = net-tools dhcp3-client build-essential pkg-config dropbear xinput xinput-calibrator x11-xserver-utils
