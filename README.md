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

## vlmcsd

## Docker build

```bash
docker pull -q openwrtorg/sdk:armvirt-64-19.07.1

docker pull -q openwrtorg/imagebuilder:armvirt-64-19.07.1
```

- <https://github.com/openwrt/docker>

## AD Block

- <https://easylist.to/>
- <https://gitee.com/privacy-protection-tools/anti-ad>

## Reference

- <https://github.com/logdns/v2ray-config>