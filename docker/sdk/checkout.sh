#!/bin/bash
#shellcheck disable=SC2312

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

function _add_feed() {
    while (($#)); do
        if ! grep -s -q "src-git $1" feeds.conf.default; then
            echo "src-git $1 $2" >>feeds.conf.default
        fi
        shift 2
    done
}

_check_param MAJOR_VERSION
if [[ ! -x staging_dir/host/bin/upx ]]; then
    curl -sL -o - https://github.com/upx/upx/releases/download/v4.1.0/upx-4.1.0-amd64_linux.tar.xz | tar --strip-components=1 -C /tmp -I xz -xf -
    cp /tmp/upx staging_dir/host/bin/upx
fi

if [[ ! -f feeds.conf.default.origin ]]; then
    cp feeds.conf.default feeds.conf.default.origin
fi
cp feeds.conf.default.origin feeds.conf.default

sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e 's|git.openwrt.org/feed/packages|github.com/openwrt/packages|g' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/routing|github.com/openwrt/routing|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -i feeds.conf.default

# Change the package definition
# sed -e '\%^src-git packages https://github.com/openwrt/packages% s%.%#&%' \
#     -e '\%^src-git-full packages https://github.com/openwrt/packages% s%.%#&%' \
#     -i feeds.conf.default

# _add_feed packages "https://github.com/Lienol/openwrt-packages;${MAJOR_VERSION}"

# Add the third party repo
# _add_feed Lienol https://github.com/Lienol/openwrt-package
# _add_feed xiaorouji https://github.com/xiaorouji/openwrt-passwall
# _add_feed fw876 https://github.com/fw876/helloworld
_add_feed kenzo https://github.com/kenzok8/openwrt-packages
_add_feed small https://github.com/kenzok8/small
# _add_feed smpackage https://github.com/kenzok8/small-package
# _add_feed jell https://github.com/kenzok8/jell
# _add_feed liuran001 "https://github.com/liuran001/openwrt-packages;packages"
# _add_feed gwlim https://github.com/gwlim/coremark-openwrt
# _add_feed shmilee https://github.com/shmilee/openwrt-shmilee-feeds.git
# small of kenzok8 has luci-app-xray
# _add_feed yichya https://github.com/yichya/luci-app-xray

scripts/feeds clean || true
./scripts/feeds update -a || true
./scripts/feeds install -a || true
rm -fr .config ./tmp || true
make defconfig || true

make -j package/feeds/luci/luci-base/compile
