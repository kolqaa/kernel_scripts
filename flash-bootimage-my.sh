#!/bin/bash

source $(pwd)/func-common.sh
source $(pwd)/func-kernel.sh

FASTBOOT=$ANDROID_PRODUCT_OUT/fastboot
ADB=$ANDROID_PRODUCT_OUT/adb

OUT=$1
BOOT_IMG=boot.img

step -a "Checking build environment..."
try check_android_env 
next "Build environment check"
echo

step "Rebooting to bootloader..."
try $ADB shell reboot bootloader
next "Reboot to bootloader"
echo

step "Flashing $BOOT_IMG..."
try $FASTBOOT devices
try $FASTBOOT flash boot_a "$OUT/$BOOT_IMG"
try $FASTBOOT flash boot_b "$OUT/$BOOT_IMG"
next "Flash $BOOT_IMG"
echo

step "Rebooting device..."
try $FASTBOOT reboot
next "Reboot device"
echo
