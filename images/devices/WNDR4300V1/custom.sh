#!/bin/bash

#shellcheck disable=SC2034
BASE_URL="${BASE_URL_PREFIX}/releases/${VERSION}/targets/ar71xx/nand"

PACKAGES=""
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-mini  -wpad-basic -dnsmasq"
PACKAGES="${PACKAGES:+$PACKAGES }bash bind-dig ca-bundle ca-certificates coreutils-base64 curl dnsmasq-full file \
ip-full ipset iptables-mod-tproxy \
libustream-openssl libpthread \
luci luci-theme-bootstrap luci-i18n-base-zh-cn \
screen tmux \
uci wpad"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-firewall-zh-cn"
if [[ ${VERSOIN} =~ 19.07 ]]; then
    PACKAGES="${PACKAGES:+$PACKAGES }-wpad-basic luci-compat uhttpd-mod-ubus"
fi

add_wireless_config() {
    cat <<EOF > "${ROOT_DIR}/custom/etc/config/wireless"
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
    add_wireless_config

    mkdir -p "${ROOT_DIR}/custom/etc/opkg"
    cat << EOF > "${ROOT_DIR}/custom/etc/opkg/customfeeds.conf"
src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/mips_24kc
src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci
EOF
}
