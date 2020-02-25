#!/bin/bash
#shellcheck disable=SC1090

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
if [[ -f "${THIS_DIR}/functions.sh" ]]; then
    source "${THIS_DIR}/functions.sh"
fi

#shellcheck disable=SC2034
BASE_URL="${BASE_URL_PREFIX}/releases/${VERSION}/targets/ramips/mt7621"

PACKAGES=""
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-mini -dnsmasq"
PACKAGES="${PACKAGES:+$PACKAGES }bash bind-dig ca-bundle ca-certificates coreutils-base64 curl dnsmasq-full file \
ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-theme-bootstrap luci-i18n-base-zh-cn luci-ssl \
screen tmux \
uci wpad"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-firewall-zh-cn"
if [[ ${VERSION} =~ 19.07 ]]; then
    PACKAGES="${PACKAGES:+$PACKAGES }-wpad-basic luci-compat luci-lib-ipkg uhttpd-mod-ubus"
fi
