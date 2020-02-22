#!/bin/bash

#shellcheck disable=SC2034
BASE_URL="${BASE_URL_PREFIX}/releases/${VERSION}/targets/x86/64"

PACKAGES=""
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-mini -dnsmasq"
PACKAGES="${PACKAGES:+$PACKAGES }bash bind-dig ca-bundle ca-certificates coreutils-base64 curl dnsmasq-full ethtool fdisk file \
ip-full ipset iptables-mod-tproxy \
libustream-openssl libpthread \
luci luci-theme-bootstrap luci-i18n-base-zh-cn \
nano tmux \
uci wpad"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-firewall-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }ChinaDNS luci-app-chinadns dns-forwarder luci-app-dns-forwarder shadowsocks-libev luci-app-shadowsocks simple-obfs ShadowVPN luci-app-shadowvpn"
PACKAGES="${PACKAGES:+$PACKAGES }busybox diffutils openssl-util ipset dnsmasq-full iptables-mod-nat-extra wget ca-bundle ca-certificates libustream-openssl"
if [[ ${VERSOIN} =~ 19.07 ]]; then
    PACKAGES="${PACKAGES:+$PACKAGES }-wpad-basic luci-compat uhttpd-mod-ubus"
fi

pre_ops() {
    for repo in "src/gz reboot_openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/x86_64" \
                "src/gz reboot_openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci"; do
        repo=$(echo "${repo}" | sed 's/\//\\\//g')
        sed -i "/telephony$/a ${repo}" repositories.conf
    done

    wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > "${ROOT_DIR}/custom/etc/chinadns_chnroute.txt"

    mkdir -p "${ROOT_DIR}/custom/etc/opkg"
    cat << EOF > "${ROOT_DIR}/custom/etc/opkg/customfeeds.conf"
src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/x86_64
src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci
EOF
}
