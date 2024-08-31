################################################################################
#
# alpine-make-rootfs
#
################################################################################

ALPINE_MAKE_ROOTFS_VERSION = 0.7.0
ALPINE_MAKE_ROOTFS_SITE = $(call github,alpinelinux,alpine-make-rootfs,v$(ALPINE_MAKE_ROOTFS_VERSION))
ALPINE_MAKE_ROOTFS_LICENSE = MIT
ALPINE_MAKE_ROOTFS_LICENSE_FILES = LICENSE

define HOST_ALPINE_MAKE_ROOTFS_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) PREFIX=$(HOST_DIR) install
endef

$(eval $(host-generic-package))
