#!/bin/bash
#shellcheck disable=SC1090

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
source "${THIS_DIR}/functions.sh"

#shellcheck disable=SC2034
BASE_URL=${BASE_URL_PREFIX}/releases/${VERSION}/targets/ramips/mt7620

PACKAGES=""
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-mini -dnsmasq"
PACKAGES="${PACKAGES:+$PACKAGES }bind-dig ca-bundle ca-certificates dnsmasq-full \
ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-theme-bootstrap \
uci wpad"
PACKAGES="${PACKAGES:+$PACKAGES }ChinaDNS luci-app-chinadns dns-forwarder luci-app-dns-forwarder shadowsocks-libev luci-app-shadowsocks simple-obfs"

pre_ops() {
    for repo in "src/gz reboot_openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/mipsel_24kc" \
                "src/gz reboot_openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci"; do
        repo=$(echo "${repo}" | sed 's/\//\\\//g')
        sed -i "/telephony$/a ${repo}" repositories.conf
    done

    wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > "${ROOT_DIR}/custom/etc/chinadns_chnroute.txt"

    add_wireless_config

    mkdir -p "${ROOT_DIR}/custom/etc/opkg"
    cat << EOF > "${ROOT_DIR}/custom/etc/opkg/customfeeds.conf"
src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/mipsel_24kc
src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci
EOF
}
