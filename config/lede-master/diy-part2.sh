#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# ------------------------------- Main source started -------------------------------
#
# Modify default theme（FROM uci-theme-bootstrap CHANGE TO luci-theme-material）
# sed -i 's/luci-theme-bootstrap/luci-theme-material/g' ./feeds/luci/collections/luci/Makefile

# Add autocore support for armvirt
# sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' package/lean/autocore/Makefile

# Set etc/openwrt_release
# sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/lean/default-settings/files/zzz-default-settings
# echo "DISTRIB_SOURCECODE='lede'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate

# Replace the default software source
# sed -i 's#openwrt.proxy.ustclug.org#mirrors.bfsu.edu.cn\\/openwrt#' package/lean/default-settings/files/zzz-default-settings
#
# 开启无线功能
cp -f $GITHUB_WORKSPACE/config/lede-master/opwifi package/base-files/files/etc/init.d/opwifi
chmod 755 package/base-files/files/etc/init.d/opwifi
sed -i "s/wireless.radio\${devidx}.disabled=1/wireless.radio\${devidx}.disabled=0/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic

# Add linkease-istore
git clone https://github.com/linkease/istore.git package/istore
# Add nas-packages-luci
git clone https://github.com/linkease/nas-packages.git package/nas
git clone https://github.com/linkease/nas-packages-luci.git package/nas_luci

# Add luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages.git package/passwall-packages
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2.git package/passwall2
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/passwall

# Add OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/OpenClash

# Add luci-app-poweroff
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff.git package/poweroff

# Add subconverter
git clone --depth=1 https://github.com/tindy2013/openwrt-subconverter

# alist
git clone --depth=1 https://github.com/sbwml/luci-app-alist.git package/alist

# Add OpenAppFilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter

# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------

# uboot-rockchip/Makefile添加tpm312设备型号
sed -i '/^# RK3566 boards/i\
define U-Boot/tpm312-rk3399\n\  $(U-Boot/rk3399/Default)\n\  NAME:=TPM312\n\  BUILD_DEVICES:= \\\n\    rockchip_tpm312\n\  DEPENDS:=+PACKAGE_u-boot-$(1):rkbin-rk3399\n\  ATF:=rk3399_bl31.elf\n\endef\n' package/boot/uboot-rockchip/Makefile

# linux/rockchip/image/armv8.mk添加tpm312设备型号
echo -e "\\ndefine Device/rockchip_tpm312
  DEVICE_VENDOR := Rockchip
  DEVICE_MODEL := TPM312
  SOC := rk3399
  SUPPORTED_DEVICES := rockchip,tpm312
  UBOOT_DEVICE_NAME := tpm312-rk3399
  IMAGE/sysupgrade.img.gz := boot-common | boot-script | pine64-img | gzip | append-metadata
endef
TARGET_DEVICES += rk3399_tpm312" >> target/linux/rockchip/image/armv8.mk

# 复制patch到对应的目录
cp -f $GITHUB_WORKSPACE/config/lede-master/etc/105-add-new-board-tpm312-uboot.patch package/boot/uboot-rockchip/patches/105-add-new-board-tpm312-uboot.patch
cp -f $GITHUB_WORKSPACE/config/lede-master/etc/995-rockchip-rk3399-tpm312-kernel.patch target/linux/rockchip/patches-6.6/995-rockchip-rk3399-tpm312-kernel.patch


# 通过命令添加对应的架构板子名称到.config文件
# 假设这些变量是从环境变量或命令行参数中获取的  
rockchip_subtarget="${SUBTARGET:-rk33xx}"                      # 如果没有提供，默认为 rk33xx  
openwrt_board="${SOURCE_BOARD:-friendlyarm_nanopi-r4se}"       # 如果没有提供，默认为 friendlyarm_nanopi-r4se  
  
# 配置文件路径（这里假设它是相对于脚本的某个位置）  
config_file=.config  # 请替换为实际的文件路径  

# 确认配置文件存在
if [ ! -f "$config_file" ]; then
    echo "Error: Configuration file not found: $config_file"
    exit 1
fi

# 根据 subtarget 构建配置字符串  
if [[ "$rockchip_subtarget" == "rk33xx" ]]; then  
    target_config="  
CONFIG_TARGET_rockchip_armv8=y  
CONFIG_TARGET_rockchip_armv8_DEVICE_$openwrt_board=y  
CONFIG_TARGET_SUBTARGET=\"armv8\"  
CONFIG_TARGET_PROFILE=\"DEVICE_$openwrt_board\"  
CONFIG_TARGET_ARCH_PACKAGES=\"aarch64_generic\"  
CONFIG_DEFAULT_TARGET_OPTIMIZATION=\"-Os -pipe -mcpu=generic\"  
CONFIG_CPU_TYPE=\"generic\"  
"  
elif [[ "$rockchip_subtarget" == "rk35xx" ]]; then  
    target_config="  
CONFIG_TARGET_rockchip_rk35xx=y  
CONFIG_TARGET_rockchip_rk35xx_DEVICE_$openwrt_board=y  
CONFIG_TARGET_SUBTARGET=\"rk35xx\"  
CONFIG_TARGET_PROFILE=\"DEVICE_$openwrt_board\"  
CONFIG_TARGET_ARCH_PACKAGES=\"aarch64_cortex-a53\"  
CONFIG_DEFAULT_TARGET_OPTIMIZATION=\"-Os -pipe -mcpu=cortex-a53\"  
CONFIG_CPU_TYPE=\"cortex-a53\"  
"  
else  
    echo "Error: Unsupported rockchip_subtarget: $rockchip_subtarget"  
    exit 1  
fi  
  
# 定义一个函数来将配置添加到文件开头（如果尚未存在）  
prepend_if_not_exists() {  
    local line="$1"  
    local file="$2"  
    # 使用 awk 来检查行是否已存在，如果不存在，则将其添加到文件开头  
    awk -v line="$line" 'NR==1{print line}1' "$file" > "$file.tmp" && mv "$file.tmp" "$file"  
}  
  
# 逐行处理配置，并添加到文件开头  
while IFS= read -r line; do  
    prepend_if_not_exists "$line" "$config_file"  
done <<< "$target_config"  
  
echo "Configuration updated for $rockchip_subtarget and $openwrt_board"
