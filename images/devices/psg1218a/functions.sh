#!/bin/bash

add_wireless_config() {
    cat <<EOF > "${ROOT_DIR}/custom/etc/config/wireless"
config wifi-device 'radio0'
        option type 'mac80211'
        option hwmode '11a'
        option path 'pci0000:00/0000:00:00.0/0000:01:00.0'
        option htmode 'VHT80'
        option country 'CN'
        option legacy_rates '1'
        option channel 'auto'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'K2'
        option encryption 'none'

config wifi-device 'radio1'
        option type 'mac80211'
        option hwmode '11g'
        option path 'platform/10180000.wmac'
        option htmode 'HT20'
        option channel 'auto'
        option country 'CN'
        option legacy_rates '1'

config wifi-iface 'default_radio1'
        option device 'radio1'
        option network 'lan'
        option mode 'ap'
        option ssid 'K2'
        option encryption 'none'
EOF
}
