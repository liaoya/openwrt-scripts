# Build OpenWrt Custom Image

Speed the build via

- start squid cache server
- change the http proxy

```bash
export http_proxy=http://localhost:3128
export https_proxy=http://localhost:3128
```

## Setup build environment

Run the following command to install the image build requirements for Ubuntu 18.04

`sudo apt-get install -y -qq subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc wget unzip python time ocaml-nox help2man texinfo yui-compressor`

## Build

Some examples, read `build.sh` for usage.

- Arm Arch64: `bash build.sh -d armvirt -p /work/openwrt/package/armvirt`
- WNDR4300V1: `bash build.sh -d WNDR4300V1 -p /work/openwrt/package/ar71xx`
- Newifi D2: `bash build.sh -d d-team_newifi-d2 -p /work/openwrt/package/mt7621`
- X86: `bash build.sh -d x64 -p /work/openwrt/package/x64`
- K2: `env PACKAGES="luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn" bash build.sh -d psg1218a -p /work/openwrt/package/mt7620`. It has only 8M Rom and 100Mb NIC, but its wireless signal is very good.

Copy the personal ipk to a separate folder and pass it to `build.sh` with `-p`.

```bash
export PACKAGES="-dnsmasq -wpad-mini \
bash bind-dig ca-bundle ca-certificates coreutils-base64 curl dnsmasq-full dropbearconvert file fish \
ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-theme-bootstrap luci-ssl \
nano tcping tmux \
uci wget wpad"

export PACKAGES="${PACKAGES:+$PACKAGES }luci-app-adbyby-plus luci-i18n-adbyby-plus-zh-cn \
luci-i18n-base-zh-cn luci-i18n-autoreboot-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci-app-ddns luci-i18n-ddns-zh-cn \
luci-app-passwall \
luci-app-smartdns luci-i18n-smartdns-zh-cn \
luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn \
luci-app-uhttpd luci-i18n-uhttpd-zh-cn \
luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn"
```

## Shadowsocks

<http://openwrt-dist.sourceforge.net/packages> is the best shadowsocks solution I found for openwrt.

```bash
wget http://openwrt-dist.sourceforge.net/openwrt-dist.pub
opkg-key add openwrt-dist.pub
```

## Issues

### K2P

Please use [PandoraBox](https://downloads.pangubox.com/pandorabox/19.01/targets/ralink/mt7621/PandoraBox-ralink-mt7621-k2p-2019-01-01-git-3e8866933-squashfs-sysupgrade.bin) or [mleaf CC build](http://www.mleaf.org/downloads/K2P-Chaos_Calmer/v1.7.2/cc-k2p-v1.7.2-16m.bin).

According to <https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=a4c84b2d734f0cba40b3d0a2183dbf221e7356e5>, Wireless radio doesn't work due to the lack of driver.
Another important is the firmware start `0xa0000`, <https://git.openwrt.org/?p=openwrt/openwrt.git;a=blob;f=target/linux/ramips/dts/K2P.dts;h=4089ce64f5da120bb4d1ac884be4168ea637f546;hb=a4c84b2d734f0cba40b3d0a2183dbf221e7356e5>

## Reference

- <https://wiki.teltonika.lt/view/UCI_command_usage>
- <http://www.panticz.de/tplink-etc-config-wireless>
- <https://www.systutorials.com/241523/how-to-advertise-different-gateway-ip-via-dhcp-in-openwrt/> : `uci add_list dhcp.lan.dhcp_option="3,192.168.1.10"`
