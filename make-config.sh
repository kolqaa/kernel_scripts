#!/bin/bash

source $(pwd)/func-common.sh
source $(pwd)/func-kernel.sh

CROSS_COMPILE=$ANDROID_TOOLCHAIN/aarch64-linux-android-

KERNEL_OUT="$(pwd)/out/obj/kernel/msm-4.4"
KERNEL_SRC=msm-4.4
KERNEL_CONFIG=.config
MODULE_SIG_KEY="/home/msimonov/mea_kernel/kernel/r1l-11449/signing_key.pem" #"$ANDROID_PRODUCT_OUT/obj/kernel/msm-4.4/certs/signing_key.pem"
MODULE_SIG_KEY_EXPR="s/CONFIG_MODULE_SIG_KEY=.*$/CONFIG_MODULE_SIG_KEY=\""${MODULE_SIG_KEY//\//\\/}"\"/g"

# Escaping / in sed's expression explanation:
# // - replase every, \/ - slash, / - with, \\/ - escaped slash (\/)

if [[ "$1" == "perf" ]]; then
	$SETCOLOR_WARNING
	echo -n "Configuring MSM auto PERFORMANCE defconfig!"
	$SETCOLOR_NORMAL
	echo
	KERNEL_DEFCONFIG=msm-auto-perf_defconfig
elif [[ "$1" == "perf-con" ]]; then
	$SETCOLOR_WARNING
	echo -n "Configuring MSM auto PERFORMANCE defconfig with enabled CONSOLE!"
	$SETCOLOR_NORMAL
	echo
	KERNEL_DEFCONFIG=msm-auto-perf-console_defconfig
else
	$SETCOLOR_WARNING
	echo -n "Configuring regular MSM auto defconfig"
	$SETCOLOR_NORMAL
	echo
	KERNEL_DEFCONFIG=msm-auto_defconfig
fi

step -a "Checking build environment..."
try check_android_env
try check_src_dir
next "Build environment check"
echo

step -a "Creating kernel config $KERNEL_DEFCONFIG..."
try make -C "$KERNEL_SRC" \
	O="$KERNEL_OUT" \
	ARCH=arm64 \
	CROSS_COMPILE="$CROSS_COMPILE" \
	KCFLAGS=-mno-android \
	$KERNEL_DEFCONFIG
next "Create kernel config $KERNEL_DEFCONFIG"
#cp ~/mea_kernel/kernel/r1l-11449/.config  $KERNEL_OUT/.config
echo

step -a "Updating CONFIG_MODULE_SIG_KEY in the kernel .config..."
try echo "Set CONFIG_MODULE_SIG_KEY=$MODULE_SIG_KEY"
try sed -i -e $MODULE_SIG_KEY_EXPR "$KERNEL_OUT/$KERNEL_CONFIG"
next "Update CONFIG_MODULE_SIG_KEY, use the key from Android build"
echo
