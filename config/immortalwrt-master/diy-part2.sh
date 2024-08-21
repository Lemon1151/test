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
# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
#
# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------
  
# 假设这些变量是从环境变量或命令行参数中获取的  
rockchip_subtarget="${1:-rk33xx}"  # 如果没有提供，默认为 rk33xx  
openwrt_board="${2:-tpm312}"       # 如果没有提供，默认为 tpm312  
  
# 配置文件路径（这里假设它是相对于脚本的某个位置）  
config_file=.config  # 请替换为实际的文件路径  
  
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
