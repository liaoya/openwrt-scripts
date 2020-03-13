# README

I use OpenWRT imagebuilder to assemble firmware for my own router.

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

## Docker build

```bash
docker pull -q openwrtorg/sdk:armvirt-64-19.07.1

docker pull -q openwrtorg/imagebuilder:armvirt-64-19.07.1
```
