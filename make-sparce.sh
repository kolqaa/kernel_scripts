#!/bin/bash

source $(pwd)/func-common.sh
source $(pwd)/func-kernel.sh

CROSS_COMPILE=$ANDROID_TOOLCHAIN/aarch64-linux-android-

KERNEL_OUT=$(pwd)/out/obj/kernel/msm-4.4
KERNEL_SRC=msm-4.4

usage()
{
	echo "Usage examples:"
	echo "check all                     $0 $KERNEL_SRC"
	echo "check code in specified dir   $0 $KERNEL_SRC/drivers/usb/dwc3/"
}

if [[ $# -eq 0 ]]; then
	usage
	exit 1
fi

step -a "Checking build environment..."
try check_android_env 
try check_src_dir
next "Build environment check"
echo

step -a "Analyzing $@ with sparce..."
try make -C $KERNEL_SRC \
	O=$KERNEL_OUT \
	ARCH=arm64 \
	CROSS_COMPILE=$CROSS_COMPILE \
	KCFLAGS=-mno-android \
	C=2 M=$(pwd)/$@
next "Analyze with sparce"
echo
