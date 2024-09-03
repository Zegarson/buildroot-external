GLIBC_INSTALL_TARGET = NO
MUSL_INSTALL_TARGET = NO
UCLIBC_INSTALL_TARGET = NO

include Makefile

ifndef ZSTDCAT
ZSTDCAT = zstdcat
INFLATE.zst = $(ZSTDCAT)
endif

define HOST_GCC_FINAL_INSTALL_LIBGCC
	-cp -dpf $(HOST_GCC_FINAL_GCC_LIB_DIR)/libgcc_s* \
		$(STAGING_DIR)/lib/
endef

define HOST_GCC_FINAL_INSTALL_LIBATOMIC
	-cp -dpf $(HOST_GCC_FINAL_GCC_LIB_DIR)/libatomic* \
		$(STAGING_DIR)/lib/
endef

define HOST_GCC_FINAL_INSTALL_SHARED_LIBS
	for i in $(HOST_GCC_FINAL_USR_LIBS) ; do \
		cp -dpf $(HOST_GCC_FINAL_GCC_LIB_DIR)/$${i}.so* \
			$(STAGING_DIR)/usr/lib/ ; \
	done
endef

define TOOLCHAIN_EXTERNAL_MOVE
        rm -rf $(TOOLCHAIN_EXTERNAL_DOWNLOAD_INSTALL_DIR)
        mkdir -p $(TOOLCHAIN_EXTERNAL_DOWNLOAD_INSTALL_DIR)
        mv $(@D)/* $(TOOLCHAIN_EXTERNAL_DOWNLOAD_INSTALL_DIR)/
        if ! test -e $(TOOLCHAIN_EXTERNAL_DOWNLOAD_INSTALL_DIR)/$(TOOLCHAIN_EXTERNAL_PREFIX)/usr; then \
                ln -sf . $(TOOLCHAIN_EXTERNAL_DOWNLOAD_INSTALL_DIR)/$(TOOLCHAIN_EXTERNAL_PREFIX)/usr; \
        fi
endef

ifeq ($(BR2_ROOTFS_MERGED_USR),y)
define SYSTEM_BIN_SBIN_LIB_DIRS
	$(INSTALL) -d -m 0755 $(1)/usr/bin
	$(INSTALL) -d -m 0755 $(1)/usr/sbin
	$(INSTALL) -d -m 0755 $(1)/usr/lib
endef
else
define SYSTEM_BIN_SBIN_LIB_DIRS
	$(INSTALL) -d -m 0755 $(1)/usr/lib
endef
endif

.PHONY: target-finalize
target-finalize: $(PACKAGES) $(TARGET_DIR) host-finalize
	@$(call MESSAGE,"Finalizing target directory hacked")

	# Official Step: Per-package rsync
	$(call per-package-rsync,$(sort $(PACKAGES)),target,$(TARGET_DIR),copy)

	# Hacked Step: Copying overlays
	$(foreach d, $(call qstrip,$(BR2_ROOTFS_OVERLAY)), \
		@$(call MESSAGE,"Copying overlay $(d)")$(sep) \
		$(Q)$(call SYSTEM_RSYNC,$(d),$(TARGET_DIR))$(sep))
	
	# Hacked Step: Executing post-build scripts
	$(foreach s, $(call qstrip,$(BR2_ROOTFS_POST_BUILD_SCRIPT)), \
		@$(call MESSAGE,"Executing post-build script $(s)")$(sep) \
		$(Q)$(EXTRA_ENV) $(s) $(TARGET_DIR) $(call qstrip,$(BR2_ROOTFS_POST_SCRIPT_ARGS))$(sep))

	# Hacked Step: Symlink sanity check
	@$(call MESSAGE,"Sanity check in target")
	$(Q)host_symlinks="$$(cd $(TARGET_DIR); find -type l -exec file {} \; | grep $(BASE_DIR))"; \
	test -n "$$host_symlinks" && { \
		echo "ERROR: The symlinks in $(TARGET_DIR) are expanded" \
			"with $(BASE_DIR) for the following symlinks:"; \
		echo "$$host_symlinks"; \
		exit 1; \
	} || true

	# Official Step: Running finalize hooks
	$(foreach hook,$(TARGET_FINALIZE_HOOKS),$($(hook))$(sep))

	# Official Step: Removing unnecessary files and directories
	rm -rf $(TARGET_DIR)/usr/include $(TARGET_DIR)/usr/share/aclocal \
		$(TARGET_DIR)/usr/lib/pkgconfig $(TARGET_DIR)/usr/share/pkgconfig \
		$(TARGET_DIR)/usr/lib/cmake $(TARGET_DIR)/usr/share/cmake \
		$(TARGET_DIR)/usr/lib/rpm $(TARGET_DIR)/usr/doc
	find $(TARGET_DIR)/usr/{lib,share}/ -name '*.cmake' -print0 | xargs -0 rm -f
	find $(TARGET_DIR)/lib/ $(TARGET_DIR)/usr/lib/ $(TARGET_DIR)/usr/libexec/ \
		\( -name '*.a' -o -name '*.la' -o -name '*.prl' \) -print0 | xargs -0 rm -f