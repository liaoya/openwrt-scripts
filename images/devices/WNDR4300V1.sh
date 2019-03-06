#!/bin/bash

#shellcheck disable=SC2034
BASE_URL="https://downloads.openwrt.org/releases/${VERSION}/targets/ar71xx/nand"

PACKAGES=""
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-mini -dnsmasq"
PACKAGES="${PACKAGES:+$PACKAGES }bash bind-dig ca-bundle ca-certificates coreutils-base64 curl dnsmasq-full file \
ip-full ipset iptables-mod-tproxy \
libustream-openssl libpthread \
luci luci-theme-bootstrap luci-i18n-base-zh-cn \
screen tmux \
uci wpad"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-firewall-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-adblock-zh-cn"
#PACKAGES="${PACKAGES:+$PACKAGES }kmod-macvlan luci-app-mwan3 luci-i18n-mwan3-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }ChinaDNS luci-app-chinadns dns-forwarder luci-app-dns-forwarder shadowsocks-libev luci-app-shadowsocks simple-obfs ShadowVPN luci-app-shadowvpn"
# for koolproxy, we can't put diffutils
PACKAGES="${PACKAGES:+$PACKAGES }openssl-util ipset dnsmasq-full iptables-mod-nat-extra wget ca-bundle ca-certificates libustream-openssl"
# PACKAGES="${PACKAGES:+$PACKAGES }luci-app-minidlna luci-i18n-minidlna-zh-cn"

add_wireless_config() {
    cat <<EOF > "${THIS_DIR}/custom/etc/config/wireless"
config wifi-device 'radio0'
        option type 'mac80211'
        option hwmode '11g'
        option path 'platform/ar934x_wmac'
        option htmode 'HT20'
        option channel 'auto'
        option disabled '0'
        option legacy_rates '1'
        option country 'CN'

config wifi-iface
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'WNDR4300'
        option wmm '0'
        option encryption 'none'

config wifi-device 'radio1'
        option type 'mac80211'
        option hwmode '11a'
        option path 'pci0000:00/0000:00:00.0'
        option channel 'auto'
        option disabled '0'
        option htmode 'HT40'
        option txpower '17'
        option country 'CN'
        option legacy_rates '1'

config wifi-iface
        option device 'radio1'
        option mode 'ap'
        option network 'lan'
        option encryption 'none'
        option ssid 'WNDR4300'
        option wmm '0'
EOF
}

pre_ops() {
    sed -i  s/'23552k(ubi),25600k@0x6c0000(firmware)'/'120832k(ubi),122880k@0x6c0000(firmware)'/ target/linux/ar71xx/image/legacy.mk
    for repo in "src/gz reboot_openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/mips_24kc" \
	            "src/gz reboot_openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci"; do
        repo=$(echo "${repo}" | sed 's/\//\\\//g')
        sed -i "/telephony$/a ${repo}" repositories.conf
    done

    wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > "${THIS_DIR}/custom/etc/chinadns_chnroute.txt"

    add_wireless_config

    mkdir -p "${THIS_DIR}/custom/etc/opkg"
    cat << EOF > "${THIS_DIR}/custom/etc/opkg/customfeeds.conf"
src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/mips_24kc
src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci
EOF
}
