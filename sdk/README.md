# Using official OpenWRT SDK to build third party package

- `bash -t armvirt-64`
- `bash -t x86-64`

## Build lean

```bash
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
