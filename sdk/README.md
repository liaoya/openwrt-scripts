# Using official OpenWRT SDK to build third party package

## Prepare

```bash
mkdir -p /work/github/{coolsnowwolf,Lienol,liaoya,pymumu}
(cd /work/github/coolsnowwolf; git clone https://github.com/coolsnowwolf/lede.git)
(cd /work/github/liaoya; git clone https://github.com/liaoya/openwrt-scripts.git)
(cd /work/github/pymumu; git clone https://github.com/pymumu/smartdns.git)
```

`988acf9daa2c80858c1fd8c097d0dffe49df858d` ssr-plus was remove again. `6c8c96cedf5b455f4eea2744aeca8d6be3fa46c2`

I find some package build issue when build with SDK `18.06`

Run `git config --global url."http://127.0.0.1:9080/".insteadOf https://` if `git-cache-http-server` installed

- `bash build.sh -d ~/Downloads/dl -n /work/armvirt -t armvirt -m -c`
- `bash build.sh -d ~/Downloads/dl -n /work/ar71xx -t ar71xx -m -c`
- `bash build.sh -d ~/Downloads/dl -n /work/mt7621 -t mt7621 -m -c`
- `bash build.sh -d ~/Downloads/dl -n /work/mt7620 -t mt7620 -m -c`
- `bash build.sh -t ~/Downloads/dl -n /work/x64 -t x64 -m -c`

## Handle Package conflicts

`kcptun` in `lienol` feed will be conflict with that in `package` feed. Refer <https://openwrt.org/docs/guide-developer/feeds>.

```bash
if grep -s -q "src-git xiaorouji" feeds.conf.default; then
    sed -i '/src-git xiaorouji/d' feeds.conf.default
fi
./scripts/feeds update -a
sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=3.3.4/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/net/shadowsocks-libev/Makefile
./scripts/feeds install -a
# Remove kcptun-c and kcptun-s
./scripts/feeds uninstall kcptun
if ! grep -s -q "src-git xiaorouji" feeds.conf.default; then
    echo "src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall" >> feeds.conf.default
fi
./scripts/feeds update -a
./scripts/feeds install -a -p lienol -f -d y
```

```bash
if ! grep -s -q "src-git xiaorouji" feeds.conf.default; then
    echo "src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall" >> feeds.conf.default
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
cp -R ${LEAN_DIR}/package/lean/ package/
LIENOL_DIR=/work/github/Lienol/openwrt
cp -R ${LIENOL_DIR}/package/lean/*smartdns* package/lean/
for pkg in $(ls -1 package/lean/); do
    if [[ -d package/feeds/lienol/${pkg} ]]; then
        rm -fr package/lean/${pkg}
    fi
done
git clone https://github.com/kuoruan/luci-app-v2ray.git package/kuoruan/luci-app-v2ray
rm -f .config
./scripts/feeds install -a
make defconfig

for config in CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray_plugin \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Redsocks2 \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server; do
    sed -i "s/${config}=y/# ${config} is not set/g" .config
done

for config in CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Simple_obfs \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Kcptun \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_DNS2SOCKS; do
    sed -i "s/# ${config} is not set/${config}=y/g" .config
done

for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin; do
    sed -i "s/${config}=y/# ${config} is not set/g" .config
done

for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ipt2socks \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_socks \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_socks \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_pdnsd \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs; do
    sed -i "s/# ${config} is not set/${config}=y/g" .config
done

make -j"$(nproc)" package/feeds/luci/luci-base/compile
for pkg in package/feeds/lienol/*; do
    pkg=$(basename "${pkg}")
    make -j"$(nproc)" package/feeds/lienol/"${pkg}"/compile || true
done
for pkg in package/lean/*; do
    pkg=$(basename "${pkg}")
    if [[ ! -d "package/feeds/lienol/${pkg}" ]]; then
        make -j"$(nproc)" package/lean/"${pkg}"/compile || true
    fi
done
for pkg in package/kuoruan/*; do
    pkg=$(basename "${pkg}")
    make -j"$(nproc)" package/kuoruan/"${pkg}"/compile
done
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
make -j$(nproc) package/lean/redsocks2/compile
make -j$(nproc) package/lean/srelay/compile

ls -1 package/feeds/lienol/ package/lean/ | grep -v -e ':$' | sed -e '/^[[:space:]]*$/d' -e 's/luci-app-//g' | sort | uniq
```

```bash
mkdir -p package/jerrykuku/
git clone https://github.com/jerrykuku/lua-maxminddb.git package/jerrykuku/lua-maxminddb
git clone https://github.com/jerrykuku/luci-app-vssr.git package/jerrykuku/luci-app-vssr
./scripts/feeds install -a
# rm -f .config
make menuconfig
make -j$(nproc) package/jerrykuku/luci-app-vssr
# git clone https://github.com/jerrykuku/luci-theme-argon.git package/jerrykuku/luci-theme-argon
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

- <https://github.com/cnsilvan/luci-app-unblockneteasemusic>
- <https://github.com/kuoruan/luci-app-kcptun>
- <https://github.com/kuoruan/luci-app-v2ray>
- <https://github.com/kuoruan/openwrt-kcptun>
- <https://github.com/kuoruan/openwrt-v2ray>
- <https://github.com/Leo-Jo-My/luci-app-ssr-plus-Jo/tree/master>
- <https://github.com/liuran001/openwrt-packages>
- <https://github.com/mwarning/openwrt-examples>
- <https://github.com/pexcn/openwrt-chinadns-ng>
- <https://github.com/project-openwrt/luci-app-vssr-1>
- <https://github.com/pymumu/luci-app-smartdns>
- <https://github.com/shadowsocks/luci-app-shadowsocks>
- <https://github.com/shadowsocks/openwrt-shadowsocks>
- <https://github.com/xiaorouji/openwrt-passwall>: contain passwall

The modified `ssr-plus` also need many dependencies. The good news is it can be built seprately.

## Reference

- builfd SSR-Plus
  - <https://www.qiqisvm.life/archives/102>
  - <https://www.solarck.com/install-ssr-plus.html>
- Lean's pakcage description
  - <https://www.right.com.cn/forum/thread-344825-1-1.html>
  - <https://www.right.com.cn/forum/thread-1237348-1-1.html>
- <https://openwrt.org/docs/guide-developer/single.package>
- <https://jarviswwong.com/compile-ipk-separately-with-openwrt.html>, solve `staging_dir/host/bin/upx: No such file or directory`
