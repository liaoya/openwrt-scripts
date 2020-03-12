# Using official OpenWRT SDK to build third party package

Run `git config --global url."http://127.0.0.1:8080/".insteadOf https://` if `git-cache-http-server` installed

- `bash build.sh -d ~/Downloads/dl -n /work/armvirt -t armvirt -m -c`
- `bash build.sh -d ~/Downloads/dl -n /work/ar71xx -t ar71xx -m -c`
- `bash build.sh -d ~/Downloads/dl -n /work/mt7621 -t mt7621 -m -c`
- `bash build.sh -t ~/Downloads/dl -n /work/x64 -t x64 -m -c`

## Handle Package conflicts

`kcptun` in `lienol` feed will be conflict with that in `package` feed. Refer <https://openwrt.org/docs/guide-developer/feeds>.

```bash
if grep -s -q "src-git lienol" feeds.conf.default; then
    sed -i '/src-git lienol/d' feeds.conf.default
fi
./scripts/feeds update -a
sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=3.3.4/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/net/shadowsocks-libev/Makefile
./scripts/feeds install -a
# Remove kcptun-c and kcptun-s
./scripts/feeds uninstall kcptun
if ! grep -s -q "src-git lienol" feeds.conf.default; then
    echo "src-git lienol https://github.com/Lienol/openwrt-package" >> feeds.conf.default
fi
./scripts/feeds update -a
./scripts/feeds install -a -p lienol -f -d y
```

```bash
if ! grep -s -q "src-git lienol" feeds.conf.default; then
    echo "src-git lienol https://github.com/Lienol/openwrt-package" >> feeds.conf.default
fi
./scripts/feeds update -a
# Remove the kcptun in package feed
rm -fr feeds/packages/net/kcptun
sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=3.3.4/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/net/shadowsocks-libev/Makefile
./scripts/feeds update -i
./scripts/feeds install -a
```

## Build lean && Lienol

```bash
LEAN_DIR=/work/github/coolsnowwolf/lede
cp ${LEAN_DIR}/package/lean/ package/ -R

for pkg in $(ls -1 package/lean/); do
    if [[ -d package/feeds/lienol/${pkg} ]]; then
        rm -fr package/lean/${pkg}
    fi
done

./scripts/feeds install -a
rm -f .config
```

Disable the following for `luci-app-ssr-plus`, then the rom size will be smaller

- `Include Redsocks2`
- `Include Shadowsocks V2ray Plugin`
- `Include ShadowsocksR Server`

The same as `luci-app-passwall`

```bash
make -j$(nproc) package/feeds/luci/luci-base/compile

make -j$(nproc) package/feeds/lienol/kcptun/compile
make -j$(nproc) package/feeds/lienol/v2ray/compile
make -j$(nproc) package/feeds/lienol/luci-app-passwall/compile
make -j$(nproc) package/feeds/lienol/luci-app-guest-wifi/compile
make -j$(nproc) package/feeds/lienol/luci-app-kcptun/compile
make -j$(nproc) package/feeds/lienol/luci-app-ramfree/compile
make -j$(nproc) package/feeds/lienol/luci-theme-bootstrap-mod/compile
make -j$(nproc) package/feeds/lienol/brook/compile
make -j$(nproc) package/feeds/lienol/trojan/compile

make -j$(nproc) package/lean/coremark/compile
make -j$(nproc) package/lean/luci-app-accesscontrol/compile
make -j$(nproc) package/lean/luci-app-adbyby-plus/compile
make -j$(nproc) package/lean/luci-app-autoreboot/compile
make -j$(nproc) package/lean/luci-app-ssr-plus/compile
make -j$(nproc) package/lean/luci-app-vlmcsd/compile

for pkg in $(ls -1 package/lean/); do
    if [[ -d package/feeds/lienol/${pkg} ]]; then
        make -j$(nproc) package/lean/${pkg}/compile
    fi
done

for pkg in $(ls -1 package/feeds/lienol/); do
    make -j$(nproc) package/feeds/lienol/${pkg}/compile
done

ls -1 package/feeds/lienol/ package/lean/ | grep -v -e ':$' | sed -e '/^[[:space:]]*$/d' -e 's/luci-app-//g' | sort | uniq
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
- <https://github.com/cnsilvan/luci-app-unblockneteasemusic>

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
- <https://openwrt.org/docs/guide-developer/single.package>
- <https://jarviswwong.com/compile-ipk-separately-with-openwrt.html>, solve `staging_dir/host/bin/upx: No such file or directory`
