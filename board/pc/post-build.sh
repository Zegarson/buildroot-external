#!/bin/sh

config_grub() {
    local BOARD_DIR=$(dirname "$0")

    cp -f "${BOARD_DIR}/grub.cfg" "$BINARIES_DIR/efi-part/EFI/BOOT/grub.cfg"
}

create_data_dir()
{
	if [ ! -d "${TARGET_DIR}/data" ]; then
		mkdir ${TARGET_DIR}/data
	fi
}

config_grub $@
create_data_dir $@