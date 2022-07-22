#!/bin/bash

set -e

function _check_param() {
    while (($#)); do
        if [[ -z ${!1} ]]; then
            echo "\${$1} is required"
            return 1
        fi
        shift 1
    done
}

_check_param MAJOR_VERSION
if [[ -n ${DEBIAN_MIRROR} ]]; then
    sudo sed -i -e "s|http://deb.debian.org|${DEBIAN_MIRROR}|g" -e "s|https://deb.debian.org|${DEBIAN_MIRROR}|g" -e "s|http://security.debian.org|${DEBIAN_MIRROR}|g" -e "s|https://security.debian.org|${DEBIAN_MIRROR}|g" /etc/apt/sources.list
fi
sudo apt update -yq
sudo apt install upx-ucl
ln -s "$(command -v upx)" staging_dir/host/bin/upx

sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -i feeds.conf.default
# Change the package definition
sed -e '/^src-git packages http/d' -i feeds.conf.default
echo "src-git packages https://github.com/Lienol/openwrt-packages;${MAJOR_VERSION}" >>feeds.conf.default
{
    echo "src-git Lienol https://github.com/Lienol/openwrt-package"
    echo "src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall"
    echo "src-git fw876 https://github.com/fw876/helloworld"
    echo "src-git kenzok8 https://github.com/kenzok8/openwrt-packages"
    echo "src-git small https://github.com/kenzok8/small"
    echo "src-git jell https://github.com/kenzok8/jell"
    echo "src-git liuran001 https://github.com/liuran001/openwrt-packages;packages"
} >>feeds.conf.default

scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a
rm -fr .config ./tmp
make defconfig

make -j package/feeds/luci/luci-base/compile
