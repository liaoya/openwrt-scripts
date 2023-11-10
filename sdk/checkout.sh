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

if [[ ${MAJOR_VERSION_NUMBER} -lt 2305 ]]; then
    rm -rf feeds/packages/lang/golang
    svn co https://github.com/openwrt/packages/branches/openwrt-23.05/lang/golang feeds/packages/lang/golang
fi

while IFS= read -r feedname; do
    ./scripts/feeds install -a -p "${feedname}" -d y -f
done < <(./scripts/feeds list -n | grep -v -e 'base\|packages\|luci\|routing\|telephony')

# python3 "${ROOT_DIR}/../remove-duplicate.py" --feeds "${SDK_DIR}"/feeds --dryrun
# ./scripts/feeds update -i

./scripts/feeds install -a
rm -fr .config ./tmp || true
make defconfig || true

make -j package/feeds/luci/luci-base/compile
