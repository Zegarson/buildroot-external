set_rauc_info()
{
	local DTB_NAME="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\(.*\)"$/\1/p' ${BR2_CONFIG} | cut -d'.' -f1)"

	# Set RAUC compatible description to the kernel devicetree name
	sed -i -e "s/%RAUC_COMPATIBLE%/${DTB_NAME}/" ${TARGET_DIR}/etc/rauc/system.conf

	# Pass VERSION as an environment variable (eg: export from a top-level Makefile)
	# If VERSION is unset, fallback to the Buildroot version
	local RAUC_VERSION=${VERSION:-${BR2_VERSION_FULL}}

	# Create rauc version file
	echo "${RAUC_VERSION}" > ${TARGET_DIR}/etc/rauc/version
}

create_data_dir()
{
	if [ ! -d "${TARGET_DIR}/data" ]; then
		mkdir ${TARGET_DIR}/data
	fi
}

patch_qemu_script()
{
	local QEMU_SCRIPT="${BINARIES_DIR}/start-qemu.sh"

	# Check if the start-qemu.sh script exists
	if [ -f "${QEMU_SCRIPT}" ]; then
		# Replace rootfs.ext2 with rootfs.squashfs
		sed -i 's/rootfs.ext2/rootfs.squashfs/g' "${QEMU_SCRIPT}"
		echo "Patched start-qemu.sh to use squashfs instead of ext2."
	else
		echo "Warning: start-qemu.sh not found. Skipping patch."
	fi
}

set_rauc_info $@
create_data_dir $@
patch_qemu_script $@