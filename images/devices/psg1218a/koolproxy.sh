#!/bin/bash
#shellcheck disable=SC1090

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
source "${THIS_DIR}/functions.sh"

#shellcheck disable=SC2034
BASE_URL=${BASE_URL_PREFIX}/releases/${VERSION}/targets/ramips/mt7620

PACKAGES=""
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-mini -dnsmasq"
PACKAGES="${PACKAGES:+$PACKAGES }luci luci-theme-bootstrap luci-i18n-base-zh-cn uci uhttpd-mod-ubus wpad"
# for koolproxy
PACKAGES="${PACKAGES:+$PACKAGES }busybox diffutils openssl-util ipset dnsmasq-full iptables-mod-nat-extra wget ca-bundle ca-certificates libustream-openssl"

pre_ops() {
    add_wireless_config
}
