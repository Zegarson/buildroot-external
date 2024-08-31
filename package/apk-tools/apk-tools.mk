APK_TOOLS_VERSION = 2.14.4
APK_TOOLS_SITE = $(call github,alpinelinux,apk-tools,v$(APK_TOOLS_VERSION))
APK_TOOLS_LICENSE = GPL-2.0
APK_TOOLS_LICENSE_FILES = LICENSE

HOST_APK_TOOLS_DEPENDENCIES = host-openssl host-zlib host-pkgconf

define HOST_APK_TOOLS_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) LUA=no -C $(@D) CFLAGS=$(HOST_CFLAGS) LDFLAGS="$(HOST_LDFLAGS)"
endef

define HOST_APK_TOOLS_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) LUA=no -C $(@D) install
endef

$(eval $(host-generic-package))
