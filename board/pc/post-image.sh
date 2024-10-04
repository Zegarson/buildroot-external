#!/bin/sh

main()
{
    local GENIMAGE_CFG=${2}
	local GENIMAGE_CFG_TMP="$(mktemp --suffix .genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
	local BOARD_PATH=$(dirname "${GENIMAGE_CFG}")

	cp ${GENIMAGE_CFG} ${GENIMAGE_CFG_TMP}
	support/scripts/genimage.sh -c ${GENIMAGE_CFG_TMP}

    rm -f ${GENIMAGE_CFG_TMP}

	exit $?
}

main $@