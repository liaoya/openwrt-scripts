#!/bin/bash
#shellcheck disable=SC2034

if [[ -n ${OPENWRT_MIRROR_PATH} ]]; then
    BASE_URL=${OPENWRT_MIRROR_PATH}/releases/${VERSION}/targets/armvirt/64
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
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-basic luci-compat luci-lib-ipkg uhttpd-mod-ubus"
