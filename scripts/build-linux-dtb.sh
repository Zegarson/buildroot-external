#!/bin/bash

CURRENT_DIR=$(pwd)
LINUX_CUSTOM_DTS="../board/st/zegarson/dts/kernel/st"
LINUX_SRC="../../buildroot/zegarson/build/linux-custom"
OUTPUT_DIR="../out"
DTS_FILE="stm32mp157d-zegarson.dts"
DTB_FILE="stm32mp157d-zegarson.dtb"

# Copy custom DTS files
cp $LINUX_CUSTOM_DTS/* "$LINUX_SRC/arch/arm/boot/dts/st/"

# Preprocess and compile DTS
cd $LINUX_SRC || exit
cpp -nostdinc -I include -I arch -undef -x assembler-with-cpp "arch/arm/boot/dts/st/$DTS_FILE" > "$DTS_FILE.preprocessed"
dtc -I dts -O dtb -o "$DTB_FILE" "$DTS_FILE.preprocessed"

cd $CURRENT_DIR
mv $LINUX_SRC/*.dtb $OUTPUT_DIR
rm $LINUX_SRC/*.preprocessed