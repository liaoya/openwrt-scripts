#!/bin/bash
#shellcheck disable=SC1090,SC2034

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
if [[ -f "${THIS_DIR}/functions.sh" ]]; then
    source "${THIS_DIR}/functions.sh"
fi

if [[ -n ${BASE_URL_PREFIX} ]]; then
    BASE_URL="${BASE_URL_PREFIX}/releases/${VERSION}/targets/ramips/mt7621"
fi

PACKAGES=${PACKAGES:-""}
PACKAGES="${PACKAGES:+$PACKAGES }-dnsmasq -wpad-mini"
PACKAGES="${PACKAGES:+$PACKAGES }bash bind-dig ca-bundle ca-certificates coreutils-base64 curl dnsmasq-full file \
ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-theme-bootstrap luci-ssl \
nano tmux \
uci wget wpad"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn"
if [[ ${VERSION} =~ 19.07 ]]; then
    PACKAGES="${PACKAGES:+$PACKAGES }-wpad-basic luci-compat luci-lib-ipkg uhttpd-mod-ubus"
fi
