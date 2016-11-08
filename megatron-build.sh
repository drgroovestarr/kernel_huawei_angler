#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz"
DTBIMAGE="dtb"
DEFCONFIG="megatron_defconfig"
KERNEL_DIR=`pwd`
RESOURCE_DIR="$KERNEL_DIR/.."
ANYKERNEL_DIR="$RESOURCE_DIR/AnyKernel2"
TOOLCHAIN_DIR="$RESOURCE_DIR/toolchain"
BUILD_DATE="$(date +"%Y%m%d")"


# Vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=drgroovestarr
export KBUILD_BUILD_HOST=triangulum

# Paths
REPACK_DIR="$ANYKERNEL_DIR"
PATCH_DIR="$ANYKERNEL_DIR/patch"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="$RESOURCE_DIR/Megatron-Release"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"

# Functions
function clean_all {
		echo; ccache -c -C echo;
		if [ -f "$MODULES_DIR/*.ko" ]; then
			rm `echo $MODULES_DIR"/*.ko"`
		fi
		cd $REPACK_DIR
		rm -rf $KERNEL
		rm -rf $DTBIMAGE
		git reset --hard > /dev/null 2>&1
		git clean -f -d > /dev/null 2>&1
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		if [ -f "$MODULES_DIR/*.ko" ]; then
			rm `echo $MODULES_DIR"/*.ko"`
		fi
		#find $MODULES_DIR/proprietary -name '*.ko' -exec cp -v {} $MODULES_DIR \;
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -v2 -o $REPACK_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm64/boot/dts/
}

function make_zip {
		cd $REPACK_DIR
		zip -x@zipexclude -r9 `echo $AK_VER`.zip *
		mv  `echo $AK_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

echo -e "${green}"
echo "********Megatron Kernel FTW********"
echo " ____ ____, ____, __, ,____,_,  _, "
echo "(-|__|-|__)(-/  \( |_/(-|_,(-|\ |  " 
echo " _|__)_|  \,_\__/,_| \,_|__,_| \|, "
echo "(    (     (     (    (    (       "
echo "  ____,_,  _,____, __,  ____,____, "
echo " (-/_|(-|\ |(-/ _,(-|  (-|_,(-|__) "
echo " _/  |,_| \|,_\__| _|__,_|__,_|  \,"
echo "(     (     (     (    (    (      "
echo "**********M*E*G*A*T*R*O*N**********"
echo "-----------------------------------"
echo "      Making Megatron Kernel       "
echo "  And formatting your hard drive:  "
echo "-----------------------------------"
echo -e "${restore}"

echo -e "${green}"
echo "What toolchain do you want to use?"
echo "1) GCC 4.9"
echo "2) GCC 5.x"
echo "3) GCC 6.x"
echo -e "${restore}"

while read -p "Select 1 - 3:" tchoice
do
case "$tchoice" in
	1 )
		export CROSS_COMPILE=$TOOLCHAIN_DIR/aarch64-linux-android-4.9-kernel/bin/aarch64-linux-android-
		TC="GCC4.9"
		echo
		echo "Using GCC 4.9, have a great day!"
		break
		;;
	2 )
		export CROSS_COMPILE=$TOOLCHAIN_DIR/aarch64-linux-android-5.x-kernel/bin/aarch64-linux-android-
		TC="GCC5.x"
		echo
		echo "Using GCC 5.x, get it!"
		break
		;;
	3 )
		export CROSS_COMPILE=$TOOLCHAIN_DIR/aarch64-linux-android-6.x-kernel/bin/aarch64-linux-android-
		TC="GCC6.x"
		echo
		echo "Using GCC 6.x, you are a pioneer"
		break
		;;
esac
done

# Kernel Details
BASE_AK_VER="MegatroN"
VER="v0.70"
AK_VER="$BASE_AK_VER-$VER-$TC-$BUILD_DATE"

while read -p "Do you want to clean out the old crusties (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "FFS! Invalid try again!"
		echo
		;;
esac
done

while read -p "Do you want to build Megatron (y/n)? " bchoice
do
case "$bchoice" in
	y|Y)
		make_kernel
		make_dtb
		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "SMH!! Invalid try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
