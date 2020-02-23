# Using official OpenWRT SDK to build third party package

- `bash -t armvirt-64`
- `bash -t x86-64`

## Build lean

```bash
echo "src-git coolsnowwolf https://github.com/coolsnowwolf/packages" >> feeds.conf.default

echo "src-git lede https://github.com/coolsnowwolf/luci" >> feeds.conf.default

make -j"$(nproc)" package/feeds/luci/luci-base/compile
# Build ssr-plus
make -j"$(nproc)" package/feeds/luci/luci-base/compile
make -j"$(nproc)" package/lean/luci-app-ssr-plus/compile
make -j"$(nproc)" package/lean/shadowsocksr-libev/compile
make -j"$(nproc)" package/lean/v2ray/compile
make -j"$(nproc)" package/lean/pdnsd-alt/compile
# Build adbyby plus
make -j"$(nproc)" package/lean/adbyby/compile
make -j"$(nproc)" package/lean/luci-app-adbyby-plus/compile
# Build vlmcsd
make -j"$(nproc)" package/lean/luci-app-vlmcsd/compile
make -j"$(nproc)" package/lean/vlmcsd/compile
```

## Build Lienol

```bash
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
```

## Install

```bash
okpg install luci-compact luci-lib-ipkg uhttpd-mod-ubus

for name in adbyby brook chinadns-ng dns2socks ipt2socks ipt2socks kcptun-client passwall pdnsd-alt shadowsocksr-libev-alt shadowsocksr-libev-ssr-local simple-obfs smartdns tcping trojan v2ray vlmcsd; do
    for pkg in $(find . -iname "*$name*"); do scp -pr $pkg root@192.168.2.10:~/; done
done
```
