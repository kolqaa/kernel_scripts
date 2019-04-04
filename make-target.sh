#!/bin/bash

source $(pwd)/func-common.sh
source $(pwd)/func-kernel.sh

CROSS_COMPILE=$ANDROID_TOOLCHAIN/aarch64-linux-android-

KERNEL_OUT=$(pwd)/out/obj/kernel/msm-4.4
KERNEL_SRC=msm-4.4

step -a "Checking build environment..."
try check_android_env 
try check_src_dir
next "Build environment check"
echo

step -a "Running make with argument(s): $@"
try make -C $KERNEL_SRC \
	O=$KERNEL_OUT \
	ARCH=arm64 \
	CROSS_COMPILE=$CROSS_COMPILE \
	KCFLAGS=-mno-android \
	$@
next "Run make with argument(s): $@"
echo
