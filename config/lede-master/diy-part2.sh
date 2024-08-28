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
# git clone https://github.com/linkease/istore.git package/istore
# Add nas-packages-luci
# git clone https://github.com/linkease/nas-packages.git package/nas
# git clone https://github.com/linkease/nas-packages-luci.git package/nas_luci

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

