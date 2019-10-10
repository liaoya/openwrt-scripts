# Newifi3 D2

## Issues

- The channel for 2.4G can not be `auto`

## Configuration

```bash
echo -e 'admin\nadmin\n' | passwd

uci set system.@system[0].hostname=newifi3-d2
uci set system.@system[0].conloglevel=2
uci set system.@system[0].cronloglevel=8

uci set luci.main.lang=zh_cn
uci set luci.themes=internal

uci set network.lan.ipaddr='192.168.3.1'

uci set wireless.radio0.country='CN'
uci set wireless.radio0.disabled='0'
uci set wireless.default_radio0.ssid='NEWIFI'
uci set wireless.default_radio0.encryption='psk2'
uci set wireless.default_radio0.key='qwertyuiop'

uci set wireless.radio1.country='CN'
uci set wireless.radio1.disabled='0'
uci set wireless.default_radio1.ssid='NEWIFI'
uci set wireless.default_radio1.encryption='psk2'
uci set wireless.default_radio1.key='qwertyuiop'

uci changes
uci commit

screen /etc/init.d/network restart
```

Run the following command to join a wireless network and remove it again will make overlayfs available

```bash
uci del firewall.cfg02dc81.network
uci set firewall.cfg02dc81.network='lan'
uci del firewall.cfg03dc81.network
uci set firewall.cfg03dc81.network='wan wan6'
uci set firewall.cfg03dc81.network='wan wan6 wwan'

uci set network.wwan=interface
uci set network.wwan.proto='dhcp'

uci set wireless.radio0.disabled='0'
uci set wireless.radio0.channel='1'
uci add wireless wifi-iface # =cfg053579
uci set wireless.@wifi-iface[-1].network='wwan'
uci set wireless.@wifi-iface[-1].ssid='k2p-400A'
uci set wireless.@wifi-iface[-1].encryption='psk2'
uci set wireless.@wifi-iface[-1].device='radio0'
uci set wireless.@wifi-iface[-1].mode='sta'
uci set wireless.@wifi-iface[-1].bssid='76:7D:24:93:40:0B'
uci set wireless.@wifi-iface[-1].key='qwertyuiop'
```

## USB Poweroff

`echo 0 > /sys/class/gpio/gpio11/value`, `echo 0 > /sys/class/gpio/power_usb3/value`

- <https://openwrt.org/docs/guide-user/hardware/usb.overview>
- <https://git.telliq.com/gtu/openwrt/blob/27014da237f172fc8459df34ab46d0460e9d7129/target/linux/ramips/dts/Newifi-D2.dts>

## Config files

### /etc/config/wireless

```text
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
```
