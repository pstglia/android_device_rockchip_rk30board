# Boot animation
TARGET_SCREEN_HEIGHT := 720
TARGET_SCREEN_WIDTH := 1366

# Inherit some common CM stuff.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

$(call inherit-product, vendor/cm/config/common_full_tv.mk)

# Inherit device configuration
$(call inherit-product, device/rockchip/rk30board/device.mk)

DEVICE_PACKAGE_OVERLAYS += device/rockchip/rk30board/overlay

PRODUCT_RUNTIMES := runtime_libart_default

## Device identifier. This must come after all inclusions
PRODUCT_NAME := lineage_rk30board
PRODUCT_BRAND := Rk3229
PRODUCT_MODEL := MXIII 4K
PRODUCT_MANUFACTURER := Unknown
PRODUCT_DEVICE := rk30board

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=rk3229 \
    BUILD_FINGERPRINT=rockchip/rk322x/rk322x:7.1/KTU84Q/eng.pstglia.20230702.193100:eng/test-keys \
    PRIVATE_BUILD_DESC="rk3229-user 7.1  WW_user_3.10.20.00_20230702_12 release-keys"
