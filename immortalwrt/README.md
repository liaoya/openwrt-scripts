# README

- <https://bingmeme.github.io/OpenWrt_CN/release/ImmortalWrtSource.html>

```bash
export PACKAGES="-dnsmasq -wpad-mini -wpad-basic -wpad-basic-wolfssl \
bash bind-dig ca-bundle ca-certificates coreutils-base64 curl dnsmasq-full dropbearconvert file \
htop ip-full ipset iptables-mod-tproxy \
libpthread \
luci-app-adbyby-plus \
luci-app-passwall luci-i18n-passwall-zh-cn \
luci-app-ssr-plus \
luci-app-uhttpd luci-i18n-uhttpd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci luci-compat luci-lib-ipkg luci-theme-bootstrap \
mtr nano tmux \
uci uhttpd-mod-ubus wget wpad \
luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn"

make image PACKAGES="$PACKAGES"

wc -l bin/targets/armvirt/64/immortalwrt-21.02.7-armvirt-64-default.manifest
```
