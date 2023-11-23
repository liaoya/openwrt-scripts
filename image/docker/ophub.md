# README

- <https://bingmeme.github.io/OpenWrt_CN/release/ImmortalWrtSource.html>

## ImmortalWRT

```bash
set -eg OPENWRT_MIRROR_PATH # fish shell
unset -v OPENWRT_MIRROR_PATH # bash shell

export PACKAGES="-dnsmasq -wpad-mini -wpad-basic \
dnsmasq-full wpad \
btrfs-progs dosfstools e2fsprogs mkf2fs xfs-mkfs \
atop bash bind-dig bzip2 ca-bundle ca-certificates cfdisk coremark coreutils-base64 curl dropbearconvert file fdisk gzip \
htop ip-full ipset iptables-mod-tproxy \
libpthread \
kcptun-client xray-plugin \
luci luci-compat luci-lib-ipkg \
luci-app-amlogic luci-i18n-amlogic-zh-cn \
luci-app-accesscontrol luci-i18n-accesscontrol-zh-cn \
luci-app-adbyby-plus luci-i18n-adbyby-plus-zh-cn \
luci-app-ikoolproxy \
luci-app-netdata luci-i18n-netdata-zh-cn \
luci-app-passwall luci-i18n-passwall-zh-cn \
luci-app-passwall2 luci-i18n-passwall2-zh-cn \
luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn \
luci-app-ttyd luci-i18n-ttyd-zh-cn \
luci-app-uhttpd luci-i18n-uhttpd-zh-cn \
luci-app-upnp luci-i18n-upnp-zh-cn \
luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn \
luci-app-zerotier luci-i18n-zerotier-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci-theme-bootstrap \
luci-theme-argon luci-app-argon-config luci-i18n-argon-config-zh-cn \
mtr nano tmux \
perl perlbase-cpan python3 \
uci uhttpd-mod-ubus wget xray-plugin xz \
"

bash build.sh -t armvirt-64 -v 21.02.7 -f ../config/custom/firefly-rk3399 -s 512

bash build.sh -t armvirt-64 -v 21.02.7 -f ../config/custom/n1 -s 512

export OPENWRT_MIRROR_PATH=http://mirror.nju.edu.cn/immortalwrt
bash build.sh -t armvirt-64 -v 21.02.7 -f ../config/custom/firefly-rk3399 -s 512 --distribution immortalwrt

bash build.sh -t armvirt-64 -v 21.02.7 -f ../config/custom/n1 -s 512 --distribution immortalwrt

wc -l bin/targets/armvirt/64/immortalwrt-21.02.7-armvirt-64-default.manifest

grep shadowsock immortalwrt-armvirt-64-21.02.7-bin/targets/armvirt/64/immortalwrt-21.02.7-armvirt-64-default.manifest
```

```bash
OPENWRT_MIRROR_PATH=http://mirror.sjtu.edu.cn/immortalwrt
sed -i /etc/opkg/distfeeds.conf \
    -e "s|http://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g" \
    -e "s|https://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g" \
    -e "s|http://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g" \
    -e "s|https://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g"
```

in ophub

```bash
mkdir -p openwrt-armvirt

sudo ./make -b firefly-rk3399 -k 6.1.60
sudo ./make -b s905d -k 6.1.62
```
