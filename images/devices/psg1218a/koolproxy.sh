#!/bin/bash

#shellcheck disable=SC2034
BASE_URL=https://downloads.openwrt.org/releases/${VERSION}/targets/ramips/mt7620

PACKAGES=""
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-mini -dnsmasq"
PACKAGES="${PACKAGES:+$PACKAGES }luci luci-theme-bootstrap luci-i18n-base-zh-cn uci wpad"
# for koolproxy
PACKAGES="${PACKAGES:+$PACKAGES }openssl-util ipset dnsmasq-full iptables-mod-nat-extra wget ca-bundle ca-certificates libustream-openssl"
