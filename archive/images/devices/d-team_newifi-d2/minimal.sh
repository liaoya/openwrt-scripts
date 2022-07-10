#!/bin/bash
#shellcheck disable=SC1091,SC2034

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
if [[ -f "${THIS_DIR}/functions.sh" ]]; then
    source "${THIS_DIR}/functions.sh"
fi

if [[ -n ${BASE_URL_PREFIX} ]]; then
    BASE_URL="${BASE_URL_PREFIX}/releases/${VERSION}/targets/ramips/mt7621"
fi

export PACKAGES="-dnsmasq -wpad-mini -wpad-basic -wpad-basic-wolfssl \
bash bind-dig ca-bundle ca-certificates coreutils-base64 curl dnsmasq-full dropbearconvert file \
htop ip-full ipset iptables-mod-tproxy \
libpthread \
luci-app-uhttpd luci-i18n-uhttpd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci luci-compat luci-lib-ipkg luci-theme-bootstrap \
mtr nano tmux \
uci uhttpd-mod-ubus wget wpad \
luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn"
