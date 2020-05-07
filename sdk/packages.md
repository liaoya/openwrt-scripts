# OpenWRT packages

- <https://github.com/project-openwrt>
- <https://github.com/project-openwrt/Lean-SSRPlus>
- <https://github.com/coolsnowwolf/lede>
- <https://github.com/stuarthua/oh-my-openwrt>

Lean's pakcage description

- <https://www.right.com.cn/forum/thread-344825-1-1.html>
- <https://www.right.com.cn/forum/thread-1237348-1-1.html>

Some guide

- <https://stuarthua.github.io/oh-my-openwrt/>

Build SSR: <https://www.qiqisvm.life/archives/102>, <https://www.solarck.com/install-ssr-plus.html>
Password to lede: <https://github.com/Lienol/openwrt-package/issues/54>
<https://awesomeopensource.com/projects/openwrt>

```bash
make package/feeds/luci/luci-base/compile
make package/lean/luci-app-adbyby-plus/compile
make package/lean/luci-app-autoreboot/compile
make package/lean/luci-app-ssr-plus/compile
make package/lean/luci-app-vlmcsd/compile
```

## Examples

- <https://github.com/mwarning/openwrt-examples>
- <https://github.com/shadowsocks/openwrt-shadowsocks>
- <https://github.com/shadowsocks/luci-app-shadowsocks>
- <https://github.com/kuoruan/luci-app-v2ray>
- <https://github.com/pexcn/openwrt-chinadns-ng>
- <https://github.com/pymumu/luci-app-smartdns>
- <https://github.com/trojan-gfw/openwrt-trojan>, build <https://www.atrandys.com/2020/2324.html>

```bash
curl -sL https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt -o /tmp/adnew.conf
/usr/bin/ssr-ad
cp -f /tmp/ad.conf /etc/dnsmasq.ssr/ad.conf
/etc/init.d/dnsmasq restart
```
