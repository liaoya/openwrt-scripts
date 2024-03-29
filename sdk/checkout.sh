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

_check_param MAJOR_VERSION_NUMBER

sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e 's|git.openwrt.org/feed/packages|github.com/openwrt/packages|g' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/routing|github.com/openwrt/routing|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -i feeds.conf.default

scripts/feeds clean || true
./scripts/feeds update -a || true

# https://github.com/sbwml/packages_lang_golang and https://github.com/kenzok8/small
# Even on OpenWrt 23.05, we need use latest golang for xray and xray-plugin build
rm -rf feeds/packages/lang/golang
# We need golang 21.x
git clone https://github.com/sbwml/packages_lang_golang -b 21.x feeds/packages/lang/golang
# svn does not work any more
# svn co https://github.com/openwrt/packages/branches/openwrt-23.05/lang/golang feeds/packages/lang/golang

while IFS= read -r feedname; do
    for item in \
        https://github.com/destan19/OpenAppFilter \
        https://github.com/fw876/helloworld \
        https://github.com/kenzok8/openwrt-packages \
        https://github.com/kenzok8/small \
        https://github.com/ophub/luci-app-amlogic; do
        if [[ $(./scripts/feeds list -s | grep -e "^${feedname} " | tr -s " " | cut -d " " -f 4) == "${item}" ]]; then
            ./scripts/feeds install -a -p "${feedname}" -d y -f
        fi
    done
done < <(./scripts/feeds list -n | grep -v -e 'base\|packages\|luci\|routing\|telephony')

# python3 "${ROOT_DIR}/../remove-duplicate.py" --feeds "${SDK_DIR}"/feeds --dryrun
# ./scripts/feeds update -i

./scripts/feeds install -a
rm -fr .config ./tmp || true
make defconfig || true

if [[ -d package/feeds/luci/luci-base ]]; then
    make -j package/feeds/luci/luci-base/compile
fi
