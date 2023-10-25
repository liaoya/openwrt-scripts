# README

- <https://bingmeme.github.io/OpenWrt_CN/release/ImmortalWrtSource.html>

```bash
export PACKAGES="-dnsmasq -wpad-mini -wpad-basic -wpad-basic-wolfssl \
bash bind-dig ca-bundle ca-certificates coremark coreutils-base64 curl dnsmasq-full dropbearconvert file \
htop ip-full ipset iptables-mod-tproxy \
libpthread \
luci-app-adbyby-plus luci-i18n-adbyby-plus-zh-cn \
luci-app-accesscontrol luci-i18n-accesscontrol-zh-cn \
luci-app-passwall luci-i18n-passwall-zh-cn \
luci-app-ssr-plus \
luci-app-uhttpd luci-i18n-uhttpd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn \
luci-app-vssr luci-i18n-vssr-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci luci-compat luci-lib-ipkg \
luci-theme-argon luci-theme-bootstrap luci-theme-material \
mtr nano tmux \
perl perlbase-cpan \
uci uhttpd-mod-ubus wget wpad \
luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn"

make image PACKAGES="$PACKAGES" ROOTFS_PARTSIZE=1024

wc -l bin/targets/armvirt/64/immortalwrt-21.02.7-armvirt-64-default.manifest
```

```bash
OPENWRT_MIRROR_PATH=http://mirror.nju.edu.cn/immortalwrt
sed -i -e "s|http://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g" -e "s|https://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g" -e "s|http://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g" -e "s|https://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g" /etc/opkg/distfeeds.conf
```
