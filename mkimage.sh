#!/bin/bash
set -e

. build/envsetup.sh >/dev/null && setpaths

export PATH=$ANDROID_BUILD_PATHS:$PATH
TARGET_PRODUCT=`get_build_var TARGET_PRODUCT`
TARGET_HARDWARE=`get_build_var TARGET_BOARD_HARDWARE`
TARGET_BOARD_PLATFORM=`get_build_var TARGET_BOARD_PLATFORM`
TARGET_DEVICE_DIR=`get_build_var TARGET_DEVICE_DIR`
PLATFORM_VERSION=`get_build_var PLATFORM_VERSION`
PLATFORM_SECURITY_PATCH=`get_build_var PLATFORM_SECURITY_PATCH`
TARGET_BUILD_VARIANT=`get_build_var TARGET_BUILD_VARIANT`
BOARD_SYSTEMIMAGE_PARTITION_SIZE=`get_build_var BOARD_SYSTEMIMAGE_PARTITION_SIZE`
BOARD_USE_SPARSE_SYSTEM_IMAGE=`get_build_var BOARD_USE_SPARSE_SYSTEM_IMAGE`
echo TARGET_BOARD_PLATFORM=$TARGET_BOARD_PLATFORM
echo TARGET_PRODUCT=$TARGET_PRODUCT
echo TARGET_HARDWARE=$TARGET_HARDWARE
echo TARGET_BUILD_VARIANT=$TARGET_BUILD_VARIANT
echo BOARD_SYSTEMIMAGE_PARTITION_SIZE=$BOARD_SYSTEMIMAGE_PARTITION_SIZE
echo BOARD_USE_SPARSE_SYSTEM_IMAGE=$BOARD_USE_SPARSE_SYSTEM_IMAGE
TARGET="withoutkernel"
if [ "$1"x != ""x  ]; then
         TARGET=$1
fi

IMAGE_PATH=rockdev/Image-$TARGET_PRODUCT
UBOOT_PATH=u-boot
KERNEL_PATH=kernel/rockchip/rk30board
KERNEL_CONFIG=$KERNEL_PATH/.config
rm -rf $IMAGE_PATH
mkdir -p $IMAGE_PATH

FSTYPE=ext4
echo system filesysystem is $FSTYPE

BOARD_CONFIG=device/rockchip/rk30board/device.mk

PARAMETER=${TARGET_DEVICE_DIR}/parameter.txt

if((BOARD_SYSTEMIMAGE_PARTITION_SIZE > 1500000000));then
    PARAMETER=${TARGET_DEVICE_DIR}/parameter_system_2.0G.txt
elif((BOARD_SYSTEMIMAGE_PARTITION_SIZE > 2147483648)); then
    PARAMETER=${TARGET_DEVICE_DIR}/parameter_system_3.0G.txt
fi

KERNEL_SRC_PATH=`grep TARGET_PREBUILT_KERNEL ${BOARD_CONFIG} |grep "^\s*TARGET_PREBUILT_KERNEL *:= *[\w]*\s" |awk  '{print $3}'`

[ $(id -u) -eq 0 ] || FAKEROOT=fakeroot

BOOT_OTA="ota"

[ $TARGET != $BOOT_OTA -a $TARGET != "withoutkernel" ] && echo "unknow target[${TARGET}],exit!" && exit 0

    if [ ! -f $OUT/kernel ]
    then
	    echo "kernel image not fount![$OUT/kernel] "
        read -p "copy kernel from TARGET_PREBUILT_KERNEL[$KERNEL_SRC_PATH] (y/n) n to exit?"
        if [ "$REPLY" == "y" ]
        then
            [ -f $KERNEL_SRC_PATH ]  || \
                echo -n "fatal! TARGET_PREBUILT_KERNEL not eixit! " || \
                echo -n "check you configuration in [${BOARD_CONFIG}] " || exit 0

            cp ${KERNEL_SRC_PATH} $OUT/kernel

        else
            exit 0
        fi
    fi

if [ $TARGET == $BOOT_OTA ]
then
	echo "make ota images... "
	echo -n "create boot.img with kernel... "
	[ -d $OUT/root ] && \
	mkbootfs $OUT/root | minigzip > $OUT/ramdisk.img && \
        truncate -s "%4" $OUT/ramdisk.img && \
        mkbootimg --kernel $OUT/kernel --ramdisk $OUT/ramdisk.img --second kernel/resource.img --os_version $PLATFORM_VERSION --os_patch_level $PLATFORM_SECURITY_PATCH --cmdline buildvariant=$TARGET_BUILD_VARIANT --output $OUT/boot.img && \
	cp -a $OUT/boot.img $IMAGE_PATH/
	echo "done."
else
	echo -n "create boot.img without kernel... "
	[ -d $OUT/root ] && \
	mkbootfs $OUT/root | minigzip > $OUT/ramdisk.img && \
        truncate -s "%4" $OUT/ramdisk.img && \
	mkbootimg --base 0 --pagesize 16384 --kernel_offset 0x60408000 --ramdisk_offset 0x62000000 --second_offset 0x60f00000 --tags_offset 0x60088000 --kernel kernel/rockchip/rk30board/arch/arm/boot/zImage --ramdisk $OUT/ramdisk.img --second kernel/rockchip/rk30board/resource.img -o $OUT/boot.img
	#rkst/mkkrnlimg $OUT/ramdisk.img $IMAGE_PATH/boot.img >/dev/null
	cp -a $OUT/boot.img $IMAGE_PATH/
	echo "done."
fi
if [ $TARGET == $BOOT_OTA ]
then
	echo -n "create recovery.img with kernel and resource... "
	[ -d $OUT/recovery/root ] && \
	mkbootfs $OUT/recovery/root | minigzip > $OUT/ramdisk-recovery.img && \
        truncate -s "%4" $OUT/ramdisk-recovery.img && \
        mkbootimg --kernel $OUT/kernel --ramdisk $OUT/ramdisk-recovery.img --second kernel/resource.img --os_version $PLATFORM_VERSION --os_patch_level $PLATFORM_SECURITY_PATCH --cmdline buildvariant=$TARGET_BUILD_VARIANT --output $OUT/recovery.img && \
	cp -a $OUT/recovery.img $IMAGE_PATH/
	echo "done."
else
	echo -n "create recovery.img without kernel and resource... "
	[ -d $OUT/recovery/root ] && \
	mkbootfs $OUT/recovery/root | minigzip > $OUT/ramdisk-recovery.img && \
        truncate -s "%4" $OUT/ramdisk-recovery.img && \
        #mkbootimg --kernel $OUT/kernel --ramdisk $OUT/ramdisk-recovery.img --os_version $PLATFORM_VERSION --os_patch_level $PLATFORM_SECURITY_PATCH --cmdline buildvariant=$TARGET_BUILD_VARIANT --output $OUT/recovery.img && \
	mkbootimg --base 0 --pagesize 16384 --kernel_offset 0x60408000 --ramdisk_offset 0x62000000 --second_offset 0x60f00000 --tags_offset 0x60088000 --kernel kernel/rockchip/rk30board/arch/arm/boot/zImage --ramdisk $OUT/ramdisk-recovery.img --second kernel/rockchip/rk30board/resource.img -o $OUT/recovery.img
        #rkst/mkkrnlimg $OUT/ramdisk-recovery.img $OUT/recovery.img
	cp -a $OUT/recovery.img $IMAGE_PATH/
	echo "done."
fi
	echo -n "create misc.img.... "
	cp -a rkst/Image/misc.img $IMAGE_PATH/misc.img
	cp -a rkst/Image/pcba_small_misc.img $IMAGE_PATH/pcba_small_misc.img
	cp -a rkst/Image/pcba_whole_misc.img $IMAGE_PATH/pcba_whole_misc.img
	echo "done."

if [ `grep "CONFIG_WIFI_BUILD_MODULE=y" $KERNEL_CONFIG` ]; then
	echo "Install wifi ko to $OUT/system/lib/modules/"
	mkdir -p $OUT/system/lib/modules/
	find kernel/rockchip/rk30board/drivers/net/wireless/rockchip_wlan/*  -name "*.ko" | xargs -n1 -i cp {} $OUT/system/lib/modules/
fi

if [ -d $OUT/system ]; then
  echo -n "create system.img..."
  if [ "$FSTYPE" = "cramfs" ]; then
    chmod -R 777 $OUT/system
      $FAKEROOT mkfs.cramfs $OUT/system $IMAGE_PATH/system.img
  elif [ "$FSTYPE" = "squashfs" ]; then
    chmod -R 777 $OUT/system
      mksquashfs $OUT/system $IMAGE_PATH/system.img -all-root >/dev/null
  elif [ "$FSTYPE" = "ext3" ] || [ "$FSTYPE" = "ext4" ]; then
    if [ "$BOARD_USE_SPARSE_SYSTEM_IMAGE" = "true" ]; then
      if [ $TARGET != $BOOT_OTA ]; then
        python ./build/tools/releasetools/build_image.py \
        $OUT/system $OUT/obj/PACKAGING/systemimage_intermediates/system_image_info.txt \
        $OUT/system.img $OUT/system
      fi
      python device/rockchip/common/sparse_tool.py $OUT/system.img
      mv $OUT/system.img.out $OUT/system.img
      cp -f $OUT/system.img $IMAGE_PATH/system.img
    else
      #system_size=`ls -l $OUT/system.img | awk '{print $5;}'`
      system_size=$BOARD_SYSTEMIMAGE_PARTITION_SIZE
      [ $system_size -gt "0" ] || { echo "Please make first!!!" && exit 1; }
      MAKE_EXT4FS_ARGS=" -L system -S $OUT/root/file_contexts -a system $IMAGE_PATH/system.img $OUT/system"
      ok=0
      while [ "$ok" = "0" ]; do
        make_ext4fs -l $system_size $MAKE_EXT4FS_ARGS >/dev/null 2>&1 &&
        tune2fs -c -1 -i 0 $IMAGE_PATH/system.img >/dev/null 2>&1 &&
        ok=1 || system_size=$(($system_size + 5242880))
        done
        e2fsck -fyD $IMAGE_PATH/system.img >/dev/null 2>&1 || true
    fi
  else
    mkdir -p $IMAGE_PATH/2k $IMAGE_PATH/4k
    mkyaffs2image -c 2032 -s 16 -f $OUT/system $IMAGE_PATH/2k/system.img
    mkyaffs2image -c 4080 -s 16 -f $OUT/system $IMAGE_PATH/4k/system.img
  fi
  echo "done."
fi
if [ -f $UBOOT_PATH/idbloader.img ]
then
        echo -n "create idbloader.img..."
        cp -a $UBOOT_PATH/idbloader.img $IMAGE_PATH/idbloader.img
        echo "done."
else
        echo "$UBOOT_PATH/idbloader.img not fount! Please make it from $UBOOT_PATH first!"
fi
if [ -f $UBOOT_PATH/uboot.img ]
then
	echo -n "create uboot.img..."
	cp -a $UBOOT_PATH/uboot.img $IMAGE_PATH/uboot.img
	echo "done."
else
	echo "$UBOOT_PATH/uboot.img not fount! Please make it from $UBOOT_PATH first!"
fi

if [ -f $UBOOT_PATH/trust.img ]
then
        echo -n "create trust.img..."
        cp -a $UBOOT_PATH/trust.img $IMAGE_PATH/trust.img
        echo "done."
else    
        echo "$UBOOT_PATH/trust.img not fount! Please make it from $UBOOT_PATH first!"
fi

if [ -f $UBOOT_PATH/*_loader_*.bin ]
then
        echo -n "create loader..."
        cp -a $UBOOT_PATH/*_loader_*.bin $IMAGE_PATH/MiniLoaderAll.bin
        echo "done."
else
	if [ -f $UBOOT_PATH/*loader*.bin ]; then
		echo -n "create loader..."
		cp -a $UBOOT_PATH/*loader*.bin $IMAGE_PATH/MiniLoaderAll.bin
		echo "done."
	elif [ "$TARGET_PRODUCT" == "px3" -a -f $UBOOT_PATH/RKPX3Loader_miniall.bin ]; then
        echo -n "create loader..."
        cp -a $UBOOT_PATH/RKPX3Loader_miniall.bin $IMAGE_PATH/MiniLoaderAll.bin
        echo "done."
	else
        echo "$UBOOT_PATH/*MiniLoaderAll_*.bin not fount! Please make it from $UBOOT_PATH first!"
	fi
fi

if [ -f $KERNEL_PATH/resource.img ]
then
        echo -n "create resource.img..."
        cp -a $KERNEL_PATH/resource.img $IMAGE_PATH/resource.img
        echo "done."
else
        echo "$KERNEL_PATH/resource.img not fount!"
fi

if [ -f $KERNEL_PATH/kernel.img ]
then
        echo -n "create kernel.img..."
        cp -a $KERNEL_PATH/kernel.img $IMAGE_PATH/kernel.img
        echo "done."
else
        echo "$KERNEL_PATH/kernel.img not fount!"
fi

if [ -f $PARAMETER ]
then
        echo -n "create parameter..."
        cp -a $PARAMETER $IMAGE_PATH/parameter.txt
        echo "done."
else
        echo "$PARAMETER not fount!"
fi

if [[ $TARGET_BOARD_PLATFORM = "rk3288" ]]; then
	echo -n "create vendor.img..."
        cp -a $OUT/vendor0.img $IMAGE_PATH/vendor0.img
        cp -a $OUT/vendor1.img $IMAGE_PATH/vendor1.img
        echo "done."
fi
chmod a+r -R $IMAGE_PATH/
