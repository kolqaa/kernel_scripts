Android Kernel Out of AFS Source Tree Build Scripts.

1. Setup Android build environment (source setup.sh from AFS source tree root or use reqular lunch command with necessary arguments)
2. AFS should be built, (tools and images from out folder are used)
3. Use scripts listed below:

- make-config.sh [perf]		make .config. To make performance .config run "./make-config.sh perf"
- make-kernel.sh [-jn ...]	to build Kernel out of AFS src tree, create boot.img and sign the image
				You can use ramdisk.img from your AFS tree out, so just run "./make-kernel.sh -j5"
				or specify another one as the first paramerer, like: "./make-kernel.sh ./ramdisk.img -j5"
- flash-bootimage.sh		flash boot.img to the target device

- make-coccicheck.sh [path]	run coccicheck (use Coccinelle  sstatic code analyzer) to specified folder "./make-coccicheck.sh msm-4.4/drivers/gpu/drm/msm/"
- make-target.sh [target]	make any target, for example: "make-target.sh clean", "make-target.sh menuconfig"
- make-cscope.sh		make cscope database



