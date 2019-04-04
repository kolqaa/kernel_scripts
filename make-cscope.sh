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

step -a "Building cscope database..."
try make -C $KERNEL_SRC \
	O=$KERNEL_OUT \
	ARCH=arm64 \
	CROSS_COMPILE=$CROSS_COMPILE \
	KCFLAGS=-mno-android \
	$@ cscope
next "Build cscope database"
echo

step "Moving cscope database to the sources location..."
try mv $KERNEL_OUT/cscope.out $KERNEL_SRC/cscope.out
try mv $KERNEL_OUT/cscope.out.in $KERNEL_SRC/cscope.out.in
try mv $KERNEL_OUT/cscope.out.po $KERNEL_SRC/cscope.out.po
next "Move cscope database"
echo
