# README

I use OpenWRT imagebuilder to assemble firmware for my own router.

## Shadowsocks Configuration

Incomplete

```bash
wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/chinadns_chnroute.txt

uci add_list shadowsocks.@access_control[0].wan_fw_ips=8.8.8.8
uci add_list shadowsocks.@access_control[0].wan_fw_ips=8.8.4.4
uci add_list shadowsocks.@access_control[0].wan_bp_ips=107.182.27.19
uci add_list shadowsocks.@access_control[0].wan_bp_ips=185.201.227.49
uci changes
uci commit
```

### Enable dns-forwarder

```bash
uci set dns-forwarder.@dns-forwarder[0].enable=1
uci set dns-forwarder.@dns-forwarder[0].listen_addr='0.0.0.0'
uci set dns-forwarder.@dns-forwarder[0].listen_port='5300'
uci set dns-forwarder.@dns-forwarder[0].dns_servers='8.8.8.8'
uci changes
uci commit
```

### Enable ChinaDNS

```bash
uci set chinadns.@chinadns[0].enable=1
uci set chinadns.@chinadns[0].server='114.114.114.114,127.0.0.1:5300'
uci changes
uci commit
```

### Change dhcp dnsmasq

```bash
uci set dhcp.@dnsmasq[0].nohosts=1
uci set dhcp.@dnsmasq[0].noresolv=1
uci set dhcp.@dnsmasq[0].local=127.0.0.1#5353
uci changes
uci commit
```

## Adblock

```bash
uci set adblock.global.adb_enabled=1
uci set adblock.reg_cn.enabled=1
uci set adblock.youtube.enabled=1
uci changes
uci commit
```

## Mirrot

- USTC
  - `sed -i 's|downloads.openwrt.org|mirrors.ustc.edu.cn/lede|g' /etc/opkg/distfeeds.conf`
  - `sed -i 's|mirrors.ustc.edu.cn/lede|downloads.openwrt.org|g' /etc/opkg/distfeeds.conf`
- tsinghua
  - `sed -i 's/downloads.openwrt.org/mirrors.tuna.tsinghua.edu.cn\/lede/g' /etc/opkg/distfeeds.conf`
  - `sed -i 's/mirrors.tuna.tsinghua.edu.cn\/lede/downloads.openwrt.org/g' /etc/opkg/distfeeds.conf`

## Koolproxy

- <http://koolshare.cn/thread-64086-1-1.html>
- <https://koolproxy.io/docs/installation>

- wndr4300: `opkg install --force-depends http://firmware.koolshare.cn/binary/KoolProxy/ar71xx/koolproxy_3.7.2-20180127_mips_24kc.ipk`
- newifi3 and k2p `opkg install --force-depends http://firmware.koolshare.cn/binary/KoolProxy/ramips/koolproxy_3.7.2-20180127_mipsel_24kc.ipk`

```bash
opkg install --force-depends http://firmware.koolshare.cn/binary/KoolProxy/luci/luci-app-koolproxy_2.0-1_all.ipk
opkg install --force-depends http://firmware.koolshare.cn/binary/KoolProxy/luci/luci-i18n-koolproxy-zh-cn_2.0-1_all.ipk

opkg install diffutils
cd /usr/share/koolproxy
curl -sL -O https://kprule.com/koolproxy.txt -O https://kprule.com/kp.dat -O https://kprule.com/daily.txt
```

- newifi3 and k2p `curl -sL https://koolproxy.com/downloads/mipsel -o /usr/share/koolproxy/koolproxy; chmod 755 /usr/share/koolproxy/koolproxy; /etc/init.d/koolproxy restart`

## vlmcsd
