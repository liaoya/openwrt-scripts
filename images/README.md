# Build OpenWrt Custom Image

## Setup build environment

Run the following command to install the image build requirements for Ubuntu 18.04

`sudo apt-get install -y -qq subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc wget unzip python time ocaml-nox help2man texinfo yui-compressor`

## Build

- Arm Arch64: `bash build.sh -d armvirt` `aarch64_generic` platform
- WNDR4300V1: `bash build.sh -d WNDR4300V1`
- Newifi D2: `bash build.sh -d d-team_newifi-d2`
- X86: `bash build.sh -d x64`
- K2: It has only 8M Rom and 100Mb NIC, but its wireless signal is very good
  - Only add chinese translation: `bash build.sh -d psg1218a -v chinese`
  - Add ShadowSocks: `bash build.sh -d psg1218a -v shadowsocks`
  - Add koolproxy support (koolproxy is not installed): `bash build.sh -d psg1218a -v koolproxy`

## Shadowsocks

<http://openwrt-dist.sourceforge.net/packages> is the best shadowsocks solution I found for openwrt.

```bash
wget http://openwrt-dist.sourceforge.net/openwrt-dist.pub
opkg-key add openwrt-dist.pub
```

## Issues

### Can't put `diffutils` in rom

koolproxy require diffutils, but we can't package it into rom. This is a know issue <https://github.com/openwrt/packages/issues/6361#issuecomment-500958659>, now there's workaround.

### K2P

Please use [PandoraBox](https://downloads.pangubox.com/pandorabox/19.01/targets/ralink/mt7621/PandoraBox-ralink-mt7621-k2p-2019-01-01-git-3e8866933-squashfs-sysupgrade.bin) or [mleaf CC build](http://www.mleaf.org/downloads/K2P-Chaos_Calmer/v1.7.2/cc-k2p-v1.7.2-16m.bin).

According to <https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=a4c84b2d734f0cba40b3d0a2183dbf221e7356e5>, Wireless radio doesn't work due to the lack of driver.
Another important is the firmware start `0xa0000`, <https://git.openwrt.org/?p=openwrt/openwrt.git;a=blob;f=target/linux/ramips/dts/K2P.dts;h=4089ce64f5da120bb4d1ac884be4168ea637f546;hb=a4c84b2d734f0cba40b3d0a2183dbf221e7356e5>

## Reference

- <https://wiki.teltonika.lt/view/UCI_command_usage>
- <http://www.panticz.de/tplink-etc-config-wireless>
- <https://www.systutorials.com/241523/how-to-advertise-different-gateway-ip-via-dhcp-in-openwrt/> : `uci add_list dhcp.lan.dhcp_option="3,192.168.1.10"`
