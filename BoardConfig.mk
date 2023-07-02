#
# Copyright 2013 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a7
#TARGET_KERNEL_CROSS_COMPILE_PREFIX := x86_64-linux-android-
TARGET_BOARD_PLATFORM := rk3229
TARGET_BOOTLOADER_BOARD_NAME := rk30sdk
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := false
TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS := true
TARGET_OTA_ASSERT_DEVICE := rk3229,rk3228
TARGET_NO_RADIOIMAGE := true

# Inline kernel building
TARGET_KERNEL_SOURCE := kernel/rockchip/rk30board
TARGET_KERNEL_ARCH := arm
BOARD_KERNEL_IMAGE_NAME := kernel
TARGET_KERNEL_CONFIG := lineage_rk30board_defconfig

BOARD_KERNEL_CMDLINE := vmalloc=496M psci=enable rockchip_jtag console=ttyFIQ0 androidboot.selinux=permissive androidboot.hardware=rk30board androidboot.console=ttyFIQ0 init=/init mtdparts=rk29xxnand:0x00002000@0x00002000(uboot),0x00004000@0x00004000(trust),0x00002000@0x00008000(misc),0x00000800@0x0000A000(baseparamer),0x00007800@0x0000A800(resource),0x00006000@0x00012000(kernel),0x0000A000@0x00018000(boot),0x0000C000@0x00022000(recovery),0x00020000@0x0002E000(backup),0x00040000@0x0004E000(cache),0x002FE000@0x0008E000(userdata),0x00002000@0x0038C000(metadata),0x00002000@0x0038E000(kpanic),0x00200000@0x00390000(system),-@0x00590000(user) storagemedia=nand uboot_logo=0x02000000@0x9dc00000:0x01000000 loader.timestamp=2016-01-26_20:19:05 hdmi.vic=65540 tve.format=1

#TARGET_RECOVERY_UPDATER_LIBS += libosip_updater
#TARGET_RECOVERY_UPDATER_EXTRA_LIBS += libintel_updater liboempartitioning_static

# Adb
BOARD_FUNCTIONFS_HAS_SS_COUNT := true

# Audio
BOARD_USES_ALSA_AUDIO := true
BOARD_USES_TINY_ALSA_AUDIO := true
TARGET_TINY_ALSA_IGNORE_SILENCE_SIZE := true

# Binder API version
TARGET_USES_32_BIT_BINDER :=true
TARGET_USES_64_BIT_BINDER := false
TARGET_SUPPORTS_32_BIT_APPS := true
TARGET_SUPPORTS_64_BIT_APPS := false

# Bluetooth
BOARD_HAVE_BLUETOOTH := false

# Camera
BOARD_CAMERA_SUPPORT ?= false

ADDITIONAL_DEFAULT_PROPERTIES += \
    media.stagefright.legacyencoder=true \
    media.stagefright.less-secure=true

# Charger
WITH_CM_CHARGER := false
BOARD_CHARGER_ENABLE_SUSPEND := true

# Dex-preoptimization: Speeds up initial boot (if we ever o a user build, which we don't)
ifeq ($(HOST_OS),linux)
  ifeq ($(TARGET_BUILD_VARIANT),user)
    ifeq ($(WITH_DEXPREOPT),)
      WITH_DEXPREOPT := true
    endif
  endif
endif

# Hardware
BOARD_HARDWARE_CLASS := device/rockchip/rk30board/cmhw

# Healthd
#BOARD_HAL_STATIC_LIBRARIES := libhealthd.clovertrail


# Opengles
BOARD_EGL_CFG := device/rockchip/rk30board/configs/egl.cfg

ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.opengles.version = 131072

BUILD_WITH_FULL_STAGEFRIGHT := true
BOARD_USES_VIDEO := true

# enabled to carry out all drawing operations performed on a View's canvas with GPU for 2D rendering pipeline.
USE_OPENGL_RENDERER := true

# Disable an optimization that causes rendering issues for us
TARGET_REQUIRES_SYNCHRONOUS_SETSURFACE := true

# Lights
TARGET_PROVIDES_LIBLIGHT := false

# Media
TARGET_NUPLAYER_CANNOT_SET_SURFACE_WITHOUT_A_FLUSH := true
BOARD_USES_WRS_OMXIL_CORE := true
BOARD_USES_MRST_OMX := true

# Media: DRM Protected Video
BOARD_WIDEVINE_OEMCRYPTO_LEVEL := 1
#USE_INTEL_SECURE_AVC := true

BOARD_GLOBAL_CFLAGS += -DGFX_BUF_EXT

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 20971520
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 25165824
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_PARTITION_SIZE := 1606418432
BOARD_CACHEIMAGE_PARTITION_SIZE := 134217728
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1073741824
BOARD_FLASH_BLOCK_SIZE := 131072

# Recovery
TARGET_NO_TWO_STEP_RECOVERY := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
BOARD_GLOBAL_CFLAGS += -DNO_SECURE_DISCARD

TARGET_RECOVERY_FSTAB := device/rockchip/rk30board/rootdir/etc/fstab.rk30board
# Security
BUILD_WITH_SECURITY_FRAMEWORK := chaabi_token
BUILD_WITH_CHAABI_SUPPORT := true

# SELinux
BOARD_SEPOLICY_DIRS += device/rockchip/rk30board/sepolicy

# Wifi
#BOARD_WLAN_DEVICE           := bcmdhd
#BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
#BOARD_HOSTAPD_PRIVATE_LIB   := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WPA_SUPPLICANT_VERSION      := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER        := NL80211
CONFIG_HS20                 := true
#WIFI_DRIVER_FW_PATH_PARAM := "/sys/module/bcm4330/parameters/firmware_path"
#WIFI_DRIVER_FW_PATH_AP    := "/system/etc/firmware/fw_bcmdhd_apsta.bin"
#WIFI_DRIVER_FW_PATH_STA   := "/system/etc/firmware/fw_bcmdhd.bin"
#WIFI_DRIVER_MODULE_ARG := "iface_name=wlan0 firmware_path=/system/etc/firmware/fw_bcmdhd.bin nvram_path=/system/etc/firmware/bcmdhd_aob.cal"

# Use the non-open-source parts, if they're present
-include vendor/rockchip/rk30board/BoardConfigVendor.mk

