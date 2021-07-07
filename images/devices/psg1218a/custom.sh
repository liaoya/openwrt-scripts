#!/bin/bash
#shellcheck disable=SC1091

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
source "${THIS_DIR}/functions.sh"

if [[ -n ${BASE_URL_PREFIX} ]]; then
    #shellcheck disable=SC2034
    BASE_URL=${BASE_URL_PREFIX}/releases/${VERSION}/targets/ramips/mt7620
fi

PACKAGES=${PACKAGES:-""}
PACKAGES="${PACKAGES:+$PACKAGES }bash curl dropbearconvert mtr nano tmux"
PACKAGES="${PACKAGES:+$PACKAGES }luci luci-ssl-openssl luci-theme-bootstrap"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-ddns luci-i18n-ddns-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-uhttpd luci-i18n-uhttpd-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-wol luci-i18n-wol-zh-cn"
if [[ ${VERSION} =~ 19.07 ]]; then
    PACKAGES="${PACKAGES:+$PACKAGES }luci-compat luci-lib-ipkg uhttpd-mod-ubus"
fi

pre_ops() {
    add_wireless_config
}
