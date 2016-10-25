#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Vars
export ARCH=arm64
export SUBARCH=arm64

# Paths
KERNEL_DIR=`pwd`

# Functions

function clean_up {
		make mrproper
}

function make_defconfig {
		echo
		cd $KERNEL_DIR
		clean_up
		make megatron_defconfig
		cp .config arch/arm64/configs/megatron_defconfig
}

echo -e "${green}"
echo "Lets regen that defconfig!!:"
echo -e "${restore}"

while read -p "Do you want to clean up old configs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_up
		echo
		echo "Old configs cleared."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to proceed (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_defconfig
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo
