# The skeleton can't depend on the toolchain, since all packages depends on the
# skeleton and the toolchain is a target package, as is skeleton.
# Hence, skeleton would depends on the toolchain and the toolchain would depend
# on skeleton.
SKELETON_ALPINELINUX_ADD_TOOLCHAIN_DEPENDENCY = NO
SKELETON_ALPINELINUX_ADD_SKELETON_DEPENDENCY = NO

# The skeleton also handles the merged /usr case in the sysroot
SKELETON_ALPINELINUX_INSTALL_STAGING = YES

SKELETON_ALPINELINUX_DEPENDENCIES = host-alpine-make-rootfs

SKELETON_ALPINELINUX_PROVIDES = skeleton

SKELETON_ALPINELINUX_PACKAGES = $(call qstrip,$(BR2_PACKAGE_SKELETON_ALPINELINUX_PACKAGES))

ifneq ($(ARCH),$(HOSTARCH))
ifeq ($(BR2_x86_64),y)
SKELETON_ALPINELINUX_QEMU_STATIC = qemu-x64_64-static
SKELETON_ALPINELINUX_ARCH = x86_64
endif

ifeq ($(BR2_aarch64),y)
SKELETON_ALPINELINUX_QEMU_STATIC = qemu-aarch64-static
SKELETON_ALPINELINUX_ARCH = aarch64
endif

ifeq ($(BR2_arm),y)
SKELETON_ALPINELINUX_ARCH = armhf
ifeq ($(BR2_cortex_a32)$(BR2_cortex_a35)$(BR2_cortex_a53)$(BR2_cortex_a57)$(BR2_cortex_a57_a53)$(BR2_cortex_a72)$(BR2_cortex_a72_a53)$(BR2_cortex_a73)$(BR2_cortex_a73_a35)$(BR2_cortex_a73_a53)$(BR2_exynos_m1)$(BR2_xgene1),y)
SKELETON_ALPINELINUX_ARCH = armv7
endif
ifeq ($(BR2_cortex_a5)$(BR2_cortex_a7)$(BR2_cortex_a8)$(BR2_cortex_a9)$(BR2_cortex_a12)$(BR2_cortex_a15)$(BR2_cortex_a15_a7)$(BR2_cortex_a17)$(BR2_cortex_a17_a7),y)
SKELETON_ALPINELINUX_ARCH = armv7
endif
SKELETON_ALPINELINUX_QEMU_STATIC = qemu-arm-static
endif

ifdef SKELETON_ALPINELINUX_QEMU_STATIC
define SKELETON_ALPINELINUX_INSTALL_QEMU_STATIC
	$(INSTALL) -D /usr/bin/$(SKELETON_ALPINELINUX_QEMU_STATIC) $(@D)/rootfs/usr/bin/$(SKELETON_ALPINELINUX_QEMU_STATIC)
endef
SKELETON_ALPINELINUX_PRE_BUILD_HOOKS += SKELETON_ALPINELINUX_INSTALL_QEMU_STATIC

define SKELETON_ALPINELINUX_REMOVE_QEMU_STATIC
	$(RM) -f $(@D)/rootfs/usr/bin/$(SKELETON_ALPINELINUX_QEMU_STATIC)
endef
SKELETON_ALPINELINUX_POST_BUILD_HOOKS += SKELETON_ALPINELINUX_REMOVE_QEMU_STATIC
endif
SKELETON_ALPINELINUX_ENV += QEMU_LD_PREFIX=$(@D)/rootfs
else
SKELETON_ALPINELINUX_ARCH = $(HOSTARCH)
endif
SKELETON_ALPINELINUX_ENV += APK_OPTS="--arch $(SKELETON_ALPINELINUX_ARCH)"

define SKELETON_ALPINELINUX_BUILD_CMDS
	mkdir -p $(@D)/rootfs/
	( cd $(@D) && $(TARGET_MAKE_ENV) $(SKELETON_ALPINELINUX_ENV) sudo alpine-make-rootfs --packages "$(SKELETON_ALPINELINUX_PACKAGES)" $(@D)/rootfs )
endef

define SKELETON_ALPINELINUX_INSTALL_TARGET_CMDS
	$(call SYSTEM_RSYNC,$(@D)/rootfs,$(TARGET_DIR))
endef

# For the staging dir, we install nothing, but we need the /lib and /usr/lib
# appropriately setup.
define SKELETON_ALPINELINUX_INSTALL_STAGING_CMDS
	$(call SYSTEM_BIN_SBIN_LIB_DIRS,$(STAGING_DIR))
	$(call SYSTEM_USR_SYMLINKS_OR_DIRS,$(STAGING_DIR))
	$(call SYSTEM_LIB_SYMLINK,$(STAGING_DIR))
endef

$(eval $(generic-package))