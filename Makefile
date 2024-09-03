PARENT_DIR := $(CURDIR)/..
override BR2_EXTERNAL += $(CURDIR)

.PHONY: _all
_all: all

$(PARENT_DIR)/buildroot/makefile: | $(PARENT_DIR)/buildroot
	ln -s $(CURDIR)/hackfile.mk $@

$(PARENT_DIR)/buildroot:
	git clone -b st/2024.02.3 https://github.com/bootlin/buildroot.git $@

%: | $(PARENT_DIR)/buildroot/makefile
	$(MAKE) -C $(PARENT_DIR)/buildroot $@ BR2_EXTERNAL="$(BR2_EXTERNAL)"