SKELETON_ALPINELINUX_ADD_TOOLCHAIN_DEPENDENCY = NO
SKELETON_ALPINELINUX_ADD_SKELETON_DEPENDENCY = NO
SKELETON_ALPINELINUX_INSTALL_STAGING = YES

SKELETON_ALPINELINUX_DEPENDENCIES = host-makedevs
SKELETON_ALPINELINUX_PROVIDES = skeleton

ifeq ($(BR2_x86_64),y)
	ALPINE_ARCH = amd64
endif

ifeq ($(BR2_aarch64),y)
	ALPINE_ARCH = arm64v8
endif

ifeq ($(BR2_arm),y)
	ALPINE_ARCH = arm32v7
endif

ROOTFS_DIR = /tmp/alpine-rootfs/$(ALPINE_ARCH)
CONTAINER_NAME = alpine-$(ALPINE_ARCH)-setup

define SKELETON_ALPINELINUX_BUILD_CMDS
	rm -rf $(ROOTFS_DIR)
	mkdir -p $(ROOTFS_DIR)

	@echo "Setting up QEMU multiarch support..."
	docker run --rm --privileged multiarch/qemu-user-static --reset --persistent yes > /dev/null

	@echo "Starting Docker container in detached mode..."
	docker start $(CONTAINER_NAME) || docker run -d --name $(CONTAINER_NAME) -v $(ROOTFS_DIR):/alpine-rootfs $(ALPINE_ARCH)/alpine sh -c "tail -f /dev/null"

	@echo "Creating initial chroot environment in Docker..."
	docker exec $(CONTAINER_NAME) sh -c '\
		apk update && \
		apk add alpine-base openrc shadow bash wpa_supplicant openssh linux-firmware-brcm libdrm util-linux nano git u-boot-tools openntpd && \
		chsh -s /bin/bash root'

	@echo "Copying files and setting permissions in Docker..."
	docker exec $(CONTAINER_NAME) sh -c '\
		for d in bin etc lib root sbin usr; do tar c "$$d" | tar x -C /alpine-rootfs; done && \
		for dir in dev proc run sys var; do mkdir -p /alpine-rootfs/$$dir; done && \
		chmod -R 777 /alpine-rootfs'

	docker stop $(CONTAINER_NAME)
endef


define SKELETON_ALPINELINUX_INSTALL_TARGET_CMDS
	$(call SYSTEM_RSYNC,$(ROOTFS_DIR),$(TARGET_DIR))
    $(call SYSTEM_BIN_SBIN_LIB_DIRS,$(TARGET_DIR))
    $(call SYSTEM_USR_SYMLINKS_OR_DIRS,$(TARGET_DIR))
    $(call SYSTEM_LIB_SYMLINK,$(TARGET_DIR))
endef

define SKELETON_ALPINELINUX_INSTALL_STAGING_CMDS
	$(call SYSTEM_RSYNC,$(ROOTFS_DIR),$(STAGING_DIR))
    $(call SYSTEM_BIN_SBIN_LIB_DIRS,$(STAGING_DIR))
    $(call SYSTEM_USR_SYMLINKS_OR_DIRS,$(STAGING_DIR))
    $(call SYSTEM_LIB_SYMLINK,$(STAGING_DIR))
endef

$(eval $(generic-package))