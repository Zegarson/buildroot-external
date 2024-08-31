IAMROOT_VERSION = v23
IAMROOT_SITE = $(call github,gportay,iamroot,$(IAMROOT_VERSION))
IAMROOT_LICENSE = LGPL-2.1+
IAMROOT_LICENSE_FILES = LICENSE
IAMROOT_DEPENDENCIES = host-pkgconfig host-patchelf host-asciidoctor

define HOST_IAMROOT_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) doc
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) PREFIX=$(HOST_DIR) ld-iamroot.so libiamroot.so
endef

define HOST_IAMROOT_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) PREFIX=$(HOST_DIR) install
endef

$(eval $(host-generic-package))