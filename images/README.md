# Build OpenWrt Custom Image

## Setup build environment

Run the following command to install the image build requirements for Ubuntu 18.04

`sudo apt-get install -y -qq subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc wget unzip python time ocaml-nox help2man texinfo yui-compressor`

## Build

Some examples, read `build.sh` for usage.

- Arm Arch64: `bash build.sh -d armvirt -p ~/Downloads/package/armvirt`
- WNDR4300V1: `bash build.sh -d WNDR4300V1 -p ~/Downloads/package/ar71xx`
- Newifi D2: `bash build.sh -d d-team_newifi-d2 -p ~/Downloads/package/mt7621`
- X86: `bash build.sh -d x64 -m`
- K2: `env PACKAGES="luci-app-wol luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn" bash build.sh -d psg1218a -p ~/Downloads/package/mt7621`. It has only 8M Rom and 100Mb NIC, but its wireless signal is very good.

Copy the personal ipk to a separate folder and pass it to `build.sh` with `-p`.

```bash
export PACKAGES="luci-app-adbyby-plus luci-app-autoreboot luci-app-passwall-plus luci-app-smartdns luci-app-ssr-plus luci-app-vlmcsd luci-app-wol \
luci-i18n-adbyby-plus-zh-cn luci-i18n-autoreboot-zh-cn luci-i18n-ssr-plus-zh-cn luci-i18n-vlmcsd-zh-cn luci-i18n-wol-zh-cn \
tcping"
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
