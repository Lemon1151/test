#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# Add a feed source
# sed -i '$a\src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default  
# sed -i '$a\src-git istore https://github.com/linkease/istore;main' feeds.conf.default  
# sed -i '$a\src-git nas https://github.com/linkease/nas-packages.git;master' feeds.conf.default  
# sed -i '$a\src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main' feeds.conf.default

# other
# rm -rf package/lean/{samba4,luci-app-samba4,luci-app-ttyd}

# 修改版本为编译日期，数字类型。
date_version=$(date +"%Y%m%d%H")
echo $date_version > version

# 为固件版本加上编译作者
author="Lemon1151"
sed -i "s/DISTRIB_DESCRIPTION.*/DISTRIB_DESCRIPTION='%D %V ${date_version} by ${author}'/g" package/base-files/files/etc/openwrt_release
sed -i "s/OPENWRT_RELEASE.*/OPENWRT_RELEASE=\"%D %V ${date_version} by ${author}\"/g" package/base-files/files/usr/lib/os-release
