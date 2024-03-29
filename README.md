# README

I use OpenWRT imagebuilder to assemble firmware for my own router. Fix the `luci` language display

```bash
opkg install --force-reinstall luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn
```

The following command fix the directory name

```bash
while IFS= read -r -d "" _dir; do
    mv "${_dir}" "${_dir}-nand"
done < <(find . -iname "ath79" -type d -print0)

while IFS= read -r -d "" _dir; do
    mv "${_dir}" $(dirname "${_dir}")/ramips-$(basename "${_dir}")
done < <(find . \( -iname "mt7621" -o -iname "mt7620" \) -type d -print0)

while IFS= read -r -d "" _dir; do
    mv "${_dir}" $(dirname "${_dir}")/x86-64
done < <(find . -iname "x64" -type d -print0)
```

## Adblock

```bash
uci set adblock.global.adb_enabled=1
uci set adblock.reg_cn.enabled=1
uci set adblock.youtube.enabled=1
uci changes
uci commit
```

## Mirror

- USTC
  - `sed -i 's|downloads.openwrt.org|mirrors.ustc.edu.cn/openwrt|g' /etc/opkg/distfeeds.conf`
  - `sed -i 's|mirrors.ustc.edu.cn/lede|downloads.openwrt.org|g' 's|mirrors.ustc.edu.cn/openwrt|downloads.openwrt.org|g' /etc/opkg/distfeeds.conf`
- tsinghua
  - `sed -i 's/downloads.openwrt.org/mirrors.tuna.tsinghua.edu.cn\/openwrt/g' /etc/opkg/distfeeds.conf`
  - `sed -i 's/mirrors.tuna.tsinghua.edu.cn\/openwrt/downloads.openwrt.org/g' /etc/opkg/distfeeds.conf`

## V2ray

```bash
wget -O kuoruan-public.key http://openwrt.kuoruan.net/packages/public.key
opkg-key add kuoruan-public.key
echo "src/gz kuoruan_universal http://openwrt.kuoruan.net/packages/releases/all" >> /etc/opkg/customfeeds.conf
opkg update
opkg install luci-app-v2ray
opkg install luci-i18n-v2ray-zh-cn
```

## AD Block

- <https://easylist.to/>
- <https://gitee.com/privacy-protection-tools/anti-ad>
- <https://adblockplus.org/zh_CN/subscriptions>
- <http://abpchina.org/forum/forum.php?mod=viewthread&tid=29667>

## Reference

- <https://github.com/logdns/v2ray-config>
- <https://github.com/topics/openwrt-feed>
- <http://files.kos.org.cn/rockchip>
