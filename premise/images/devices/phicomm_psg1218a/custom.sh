#!/bin/bash
#shellcheck disable=SC1091

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
source "${THIS_DIR}/functions.sh"

if [[ -n ${OPENWRT_MIRROR_PATH} ]]; then
    #shellcheck disable=SC2034
    BASE_URL=${OPENWRT_MIRROR_PATH}/releases/${VERSION}/targets/ramips/mt7620
fi

PACKAGES=${PACKAGES:-""}
_ADD_PACKAGE bash curl dropbearconvert mtr nano tmux
_ADD_PACKAGE luci luci-theme-bootstrap
_ADD_PACKAGE luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn
_ADD_PACKAGE luci-app-ddns luci-i18n-ddns-zh-cn
_ADD_PACKAGE luci-app-uhttpd luci-i18n-uhttpd-zh-cn
_ADD_PACKAGE luci-app-wol luci-i18n-wol-zh-cn
_ADD_PACKAGE luci-compat luci-lib-ipkg uhttpd-mod-ubus

pre_ops() {
    add_wireless_config
}
