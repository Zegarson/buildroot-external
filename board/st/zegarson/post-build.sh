add_wifi_fw_symlinks()
{
	if ! grep -q "^BR2_PACKAGE_LINUX_FIRMWARE=y" ${BR2_CONFIG}; then
		return
	fi

	pushd ${TARGET_DIR}/lib/firmware/brcm

	for board in stm32mp157d-zegarson; do
		ln -sf brcmfmac43439-sdio.bin brcmfmac43439-sdio.st,${board}-mx.bin
		ln -sf brcmfmac43439-sdio.txt brcmfmac43439-sdio.st,${board}-mx.txt
		ln -sf brcmfmac43439-sdio.clm_blob brcmfmac43439-sdio.st,${board}-mx.clm_blob
	done

	popd
}

add_wifi_fw_symlinks $@