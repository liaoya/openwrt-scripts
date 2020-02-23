#!/bin/bash

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
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-adblock-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }ChinaDNS luci-app-chinadns dns-forwarder luci-app-dns-forwarder shadowsocks-libev luci-app-shadowsocks simple-obfs ShadowVPN luci-app-shadowvpn"
# for adbyby
PACKAGES="${PACKAGES:+$PACKAGES }libstdcpp kmod-nls-base kmod-nls-utf8"
if [[ ${VERSOIN} =~ 19.07 ]]; then
    PACKAGES="${PACKAGES:+$PACKAGES }-wpad-basic luci-compat luci-lib-ipkg uhttpd-mod-ubus"
fi

add_wireless_config() {
    cat <<EOF > "${ROOT_DIR}/custom/etc/config/wireless"
config wifi-device 'radio0'
        option type 'mac80211'
        option hwmode '11g'
        option path 'pci0000:00/0000:00:01.0/0000:02:00.0'
        option htmode 'HT20'
        option channel '11'
        option legacy_rates '1'
        option country 'CN'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option encryption 'none'
        option ssid 'NEWIFI3'

config wifi-device 'radio1'
        option type 'mac80211'
        option hwmode '11a'
        option path 'pci0000:00/0000:00:00.0/0000:01:00.0'
        option htmode 'VHT80'
        option channel 'auto'
        option legacy_rates '1'
        option country 'CN'

config wifi-iface 'default_radio1'
        option device 'radio1'
        option network 'lan'
        option mode 'ap'
        option encryption 'none'
        option ssid 'NEWIFI3'
EOF
}

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
