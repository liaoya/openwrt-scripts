# Using official OpenWRT SDK to build third party package

- `bash -t armvirt-64`
- `bash -t x86-64`

## Build lean && Lienol

```bash
LEAN_DIR=/work/github/coolsnowwolf/lede
cp ${LEAN_DIR}/package/lean/ package/ -R

[ -f feeds.conf.default.origin ] || cp feeds.conf.default feeds.conf.default.origin
[ -f feeds.conf.default.origin ] && cp feeds.conf.default.origin feeds.conf.default
echo "src-git lienol https://github.com/Lienol/openwrt-package" >> feeds.conf.default

sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e 's|git.openwrt.org/feed/packages|github.com/openwrt/packages|g' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -i feeds.conf.default

./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a

sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=3.3.4/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' package/feeds/packages/shadowsocks-libev/Makefile
```

Disable the following for `luci-app-ssr-plus`, then the rom size will be smaller

- `Include Redsocks2`
- `Include Shadowsocks V2ray Plugin`
- `Include ShadowsocksR Server`

```bash
make -j$(nproc) package/feeds/luci/luci-base/compile

make -j$(nproc) package/lean/coremark/compile
make -j$(nproc) package/lean/luci-app-adbyby-plus/compile
make -j$(nproc) package/lean/luci-app-autoreboot/compile
make -j$(nproc) package/lean/luci-app-ssr-plus/compile
make -j$(nproc) package/lean/luci-app-vlmcsd/compile
make -j$(nproc) package/lean/kcptun/compile

make -j"$(nproc)" package/feeds/lienol/brook/compile
make -j"$(nproc)" package/feeds/lienol/luci-app-guest-wifi/compile
make -j"$(nproc)" package/feeds/lienol/luci-app-kcptun/compile
make -j"$(nproc)" package/feeds/lienol/luci-app-passwall/compile
make -j"$(nproc)" package/feeds/lienol/luci-app-ramfree/compile
make -j"$(nproc)" package/feeds/lienol/luci-theme-bootstrap-mod/compile
make -j"$(nproc)" package/feeds/lienol/trojan/compile

for pkg in $(ls -1 package/lean/); do
    make -j"$(nproc)" package/lean/${pkg}/compile
done

for pkg in $(ls -1 package/feeds/lienol/); do
    make -j"$(nproc)" package/feeds/lienol/${pkg}/compile
done

# Have issues
make -j"$(nproc)" package/feeds/packages/kcptun/compile
```

### Fix lean ssr-ad

```bash
curl -sL https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt -o /tmp/adnew.conf
/usr/bin/ssr-ad
cp -f /tmp/ad.conf /etc/dnsmasq.ssr/ad.conf
/etc/init.d/dnsmasq restart
```

## Install

```bash
okpg install luci-compact luci-lib-ipkg uhttpd-mod-ubus

for name in adbyby adguardhome autoreboot brook chinadns-ng dns2socks ipt2socks kcptun passwall pdnsd ramfree shadowsocks simple-obfs smartdns srelay ssr-plus tcping trojan v2ray vlmcsd; do
    for pkg in $(find bin -iname "*$name*.ipk"); do sshpass -p password scp -pr $pkg root@192.168.2.10:/tmp/tmp; done
done
```

## Other Packages

- <https://github.com/mwarning/openwrt-examples>
- <https://github.com/shadowsocks/openwrt-shadowsocks>
- <https://github.com/shadowsocks/luci-app-shadowsocks>
- <https://github.com/kuoruan/luci-app-v2ray>
- <https://github.com/pexcn/openwrt-chinadns-ng>
- <https://github.com/pymumu/luci-app-smartdns>
- <https://github.com/project-openwrt/luci-app-vssr-1>
- <https://github.com/Leo-Jo-My/luci-app-ssr-plus-Jo/tree/master>
- <https://github.com/kuoruan/openwrt-kcptun>

The modified `ssr-plus` also need many dependencies. The good news is it can be built seprately.

## Reference

- builfd SSR-Plus
  - <https://www.qiqisvm.life/archives/102>
  - <https://www.solarck.com/install-ssr-plus.html>
- build lean
  - <https://github.com/Lienol/openwrt-package/issues/54>, integrate lean package to Lienol on `19.07`
- Lean's pakcage description
  - <https://www.right.com.cn/forum/thread-344825-1-1.html>
  - <https://www.right.com.cn/forum/thread-1237348-1-1.html>
