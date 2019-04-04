#!/bin/bash

source $(pwd)/func-common.sh
source $(pwd)/func-kernel.sh

CROSS_COMPILE=$ANDROID_TOOLCHAIN/aarch64-linux-android-
PACKKERNELIMG=$ANDROID_BUILD_TOP/out/host/linux-x86/bin/packkernelimg
MKBOOTIMG=$ANDROID_BUILD_TOP/out/host/linux-x86/bin/mkbootimg
BOOT_SIGNER=$ANDROID_BUILD_TOP/out/host/linux-x86/bin/boot_signer

KERNEL_SRC=msm-4.4
OUT=$(pwd)/out
KERNEL_OUT=$OUT/obj/kernel/msm-4.4
KERNEL_IMG=$KERNEL_OUT/arch/arm64/boot/Image
KERNEL_IMG_COMPRESSED=Image.gz-dtb
KERNEL_DT=$KERNEL_OUT/arch/arm64/boot/dts/qcom

VERITY_SIGNING_KEY=$ANDROID_BUILD_TOP/build/target/product/security/verity.pk8
VERITY_SIGNING_CERT=$ANDROID_BUILD_TOP/build/target/product/security/verity.x509.pem

KERNEL_DT_LIST="\
 apq8096pro-v1.1-auto-fca-r1l-dv1.dtb\
 msm8996pro-auto-icup2.dtb\
 apq8096pro-v1.1-auto-icup2.dtb\
 msm8996-v3-pm8004-agave-icup2.dtb\
 msm8996-v3-pm8004-agave-mpb.dtb\
 msm8996pro-auto-mpb.dtb\
 apq8096pro-v1.1-auto-mpb.dtb\
 msm8996pro-auto-fca-r1-cob.dtb\
 msm8996pro-auto-fca-r1-sip.dtb\
 apq8096-v3-auto-dragonboard-vio-card.dtb\
 msm8996pro-auto-adp.dtb\
 msm8996-v3-pm8004-mmxf-adp.dtb\
 msm8996-v3-pm8004-agave-adp-lite.dtb\
 msm8996pro-auto-adp-lite.dtb\
 msm8996pro-auto-cdp.dtb\
 msm8996pro-auto-adp-lite.dtb\
 apq8096pro-v1.1-auto-adp.dtb\
 apq8096pro-v1.1-auto-adp-lite.dtb\
 apq8096pro-v1.1-auto-cdp.dtb\
 msm8996-v2-pmi8994-cdp.dtb\
 msm8996-v2-pmi8994-mtp.dtb\
 msm8996-v2-pmi8994-pmk8001-cdp.dtb\
 msm8996-v2-pmi8994-pmk8001-mtp.dtb\
 msm8996-v2-dtp.dtb msm8996-v3-auto-cdp.dtb\
 msm8996-v3-auto-adp.dtb\
 msm8996-v3-pmi8994-cdp.dtb\
 msm8996-v3-pmi8994-mtp.dtb\
 msm8996-v3-pmi8996-cdp.dtb\
 msm8996-v3-pmi8996-mtp.dtb\
 msm8996-v3-pmi8996-pmk8001-cdp.dtb\
 msm8996-v3-pmi8996-pmk8001-mtp.dtb\
 msm8996-v3-dtp.dtb\
 msm8996-v3-pm8004-agave-adp.dtb\
"
KERNEL_CMDLINE_VERITYKEYID=$(\
 openssl x509 -in ${VERITY_SIGNING_CERT} -text | \
 grep keyid | \
 sed 's/://g' | \
 tr -d '[:space:]' | \
 tr '[:upper:]' '[:lower:]' | \
 sed 's/keyid//g' \
)

# Add options below to the command line if necessary:

# ignore_loglevel
# debug
# slub_debug=FZU\

KERNEL_CMDLINE="\
 console=ttyMSM0,115200,n8\
 androidboot.console=ttyMSM0\
 androidboot.hardware=qcom\
 user_debug=31\
 msm_rtb.filter=0x237\
 ehci-hcd.park=3\
 lpm_levels.sleep_disabled=1\
 cma=16M@0-0xffffffff\
 androidboot.selinux=permissive\
 no_console_suspend\
 loglevel=3\
 log_buf_len=1M\
 buildvariant=userdebug\
 veritykeyid=id:$KERNEL_CMDLINE_VERITYKEYID\
"

if [[ "$1" == *"ramdisk"* ]]; then
	RAMDISK=$1
	shift
else
	# QTI uses ramdisk-recovery.img instead of ramdisk.img (due to verified boot, A/B, etc)
	RAMDISK=$ANDROID_PRODUCT_OUT/ramdisk-recovery.img
fi

step -a "Checking build environment..."
try check_android_env 
try check_src_dir
next "Build environment check"
echo

step "Cleaning DTBs (WA for QTI Android BSP build system issue)..."
try rm -rf $KERNEL_OUT/arch/arm64/boot/
next "Clean DTBs"
echo

echo "KERNEL_SRC=$KERNEL_SRC"
echo "KERNEL_OUT=$KERNEL_OUT"
echo "CROSS_COMPILE=$CROSS_COMPILE"
echo "KERNEL_IMG_COMPRESSED=$KERNEL_IMG_COMPRESSED"

step -a "Building kernel..."
try make -C $KERNEL_SRC \
	O=$KERNEL_OUT \
	ARCH=arm64 \
	CROSS_COMPILE=$CROSS_COMPILE \
	KCFLAGS=-mno-android \
	$@ $KERNEL_IMG_COMPRESSED
next "Kernel build"
echo

step -a "Make boot image..."
echo "Use ramdisk image: $RAMDISK"
try $PACKKERNELIMG \
	--kernel "$KERNEL_IMG" \
	--dt "$KERNEL_DT" \
	--dt_list "$KERNEL_DT_LIST"

try $MKBOOTIMG  \
	--kernel "$KERNEL_IMG" \
	--ramdisk "$RAMDISK" \
	--cmdline "$KERNEL_CMDLINE" \
	--base 0x80000000 \
	--pagesize 4096 \
	--os_version 8.1.0 \
	--os_patch_level 2018-05-05 \
	--output "$OUT/boot.img"
next "Boot image"
echo

step -a "Signing boot.img..."
try $BOOT_SIGNER \
	/boot \
	"$OUT/boot.img" \
	"$VERITY_SIGNING_KEY" \
	"$VERITY_SIGNING_CERT" \
	"$OUT/boot.img"
next "Sign boot.img"
echo
