# README

**Use <https://firmware-selector.openwrt.org> if you want a image with customize package.**

User OpenWRT docker image to build firmware

There're no image after `18.06.7` for `18.06` series

- `23.05`
  - `docker.io/openwrt/imagebuilder:armsr-armv8-23.05.2` (<https://openwrt.org/releases/23.05/notes-23.05.2>)
  - `docker.io/openwrt/imagebuilder:ath79-nand-23.05.2`
  - `docker.io/openwrt/imagebuilder:ramips-mt7620-23.05.2`
  - `docker.io/openwrt/imagebuilder:ramips-mt7621-23.05.2`
  - `docker.io/openwrt/imagebuilder:x86-64-23.05.2`
- `22.03`
  - `docker.io/openwrt/imagebuilder:armvirt-64-22.03.5`
  - `docker.io/openwrt/imagebuilder:ath79-nand-22.03.5`
  - `docker.io/openwrt/imagebuilder:ramips-mt7620-22.03.5`
  - `docker.io/openwrt/imagebuilder:ramips-mt7621-22.03.5`
  - `docker.io/openwrt/imagebuilder:x86-64-22.03.5`
- `21.02`
  - `docker.io/openwrt/imagebuilder:armvirt-64-21.02.7`
  - `docker.io/openwrt/imagebuilder:ath79-nand-21.02.7`
  - `docker.io/openwrt/imagebuilder:ramips-mt7620-21.02.7`
  - `docker.io/openwrt/imagebuilder:ramips-mt7621-21.02.7`
  - `docker.io/openwrt/imagebuilder:x86-64-21.02.7`
- `19.07`
  - `docker.io/openwrt/imagebuilder:x86-64-19.07.10`
- `18.06`
  - `docker.io/openwrtorg/imagebuilder:x86-64-18.06.7`

- `23.05`
  - `docker.io/immortalwrt/imagebuilder:armsr-armv8-openwrt-23.05.1`
  - `docker.io/immortalwrt/imagebuilder:ath79-nand-openwrt-23.05.1`
  - `docker.io/immortalwrt/imagebuilder:ramips-mt7620-openwrt-23.05.1`
  - `docker.io/immortalwrt/imagebuilder:ramips-mt7621-openwrt-23.05.1`
  - `docker.io/immortalwrt/imagebuilder:x86-64-openwrt-23.05.1`
- `21.02`
  - `docker.io/immortalwrt/imagebuilder:armvirt-64-openwrt-21.02.7`
  - `docker.io/immortalwrt/imagebuilder:ath79-nand-openwrt-21.02.7`
  - `docker.io/immortalwrt/imagebuilder:ramips-mt7620-openwrt-21.02.7`
  - `docker.io/immortalwrt/imagebuilder:ramips-mt7621-openwrt-21.02.7`
  - `docker.io/immortalwrt/imagebuilder:x86-64-openwrt-21.02.7`

## Newifi-D2

```bash
# OpenWRT 23.05 and OpenWRT 21.02

unset -v OPENWRT_MIRROR_PATH
unset -v PACKAGES
export PACKAGES="-dnsmasq -wpad-basic -wpad-basic-mbedtls \
dnsmasq-full wpad \
atop bash bind-dig bzip2 ca-bundle ca-certificates cfdisk coremark coreutils-base64 curl dropbearconvert file fdisk gzip \
htop ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-compat luci-lib-ipkg \
luci-app-upnp luci-i18n-upnp-zh-cn \
luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn \
luci-app-zerotier luci-i18n-zerotier-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci-theme-bootstrap \
mtr nano tmux \
uci wget-ssl xz \
"

bash -x build.sh -t ramips-mt7621 -p d-team_newifi-d2
```

## K2P

```bash
# OpenWRT 23.05 and OpenWRT 21.02

unset -v OPENWRT_MIRROR_PATH
unset -v PACKAGES
export PACKAGES="
bash dropbearconvert file \
htop ipset \
luci luci-compat luci-lib-ipkg \
luci-app-upnp luci-i18n-upnp-zh-cn \
luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn \
luci-app-zerotier luci-i18n-zerotier-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci-theme-argon luci-app-argon-config luci-i18n-argon-config-zh-cn \
luci-theme-bootstrap \
mtr tmux \
uci \
"

bash -x build.sh -t ramips-mt7621 -p phicomm_k2p
```

## WNDR 4300

```bash
unset -v OPENWRT_MIRROR_PATH
unset -v PACKAGES
export PACKAGES="-dnsmasq -wpad-basic -wpad-basic-mbedtls -wpad-openssl \
dnsmasq-full wpad-mbedtls \
atop bash bind-dig bzip2 ca-bundle ca-certificates cfdisk coremark coreutils-base64 curl dropbearconvert file fdisk gzip \
htop ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-compat luci-lib-ipkg \
luci-app-upnp luci-i18n-upnp-zh-cn \
luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn \
luci-app-zerotier luci-i18n-zerotier-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci-theme-bootstrap \
mtr nano tmux \
uci wget-ssl xz \
"

bash build.sh -t ath79-nand -p netgear_wndr4300
```

## X86-64

```bash
# The package must be declare external
unset -v PACKAGES
PACKAGES="-dnsmasq dnsmasq-full \
atop bash bind-dig bzip2 ca-bundle ca-certificates cfdisk coremark coreutils-base64 curl dropbearconvert file fdisk gzip \
htop ip-full ipset \
luci luci-compat luci-lib-ipkg \
luci-app-uhttpd luci-i18n-uhttpd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci-theme-bootstrap \
mtr nano python3 tmux \
uci uhttpd-mod-ubus wget-ssl xz \
"
PACKAGES="${PACKAGES:+$PACKAGES }coremark"
PACKAGES="${PACKAGES:+$PACKAGES }luci-theme-argon luci-app-argon-config luci-i18n-argon-config-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-adbyby-plus luci-i18n-adbyby-plus-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn vlmcsd"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-accesscontrol luci-i18n-accesscontrol-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-netdata luci-i18n-netdata-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-ttyd luci-i18n-ttyd-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-passwall luci-i18n-passwall-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-zerotier luci-i18n-zerotier-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }kcptun-client xray-plugin"
export PACKAGES

export OPENWRT_MIRROR_PATH=http://mirrors.cloud.tencent.com/openwrt
export OPENWRT_MIRROR_PATH=http://mirrors.aliyun.com/openwrt

bash -x build.sh -t x86-64 -s 512 -f ../config/custom/x86-64

bash -x build.sh -t x86-64 -s 512 -v 21.02.7 -f ../config/custom/x86-64

bash -x build.sh -t x86-64 -s 512 --distribution ImmortalWrt -v 21.02.7 -f ../config/custom/x86-64

bash -x build.sh -t x86-64 -s 512 --distribution ImmortalWrt -v 23.05.1 -f ../config/custom/x86-64
```

## N1

```bash
uci del dhcp.lan.ra_flags
uci add_list dhcp.lan.ra_flags='none'

uci set network.lan.device='eth0'
```

## nftable

```bash
opkg install iptables-nft

sed -i 's/iptables/iptables-translate/g' /etc/init.d/mia
```

```text
build@5d97695460c4:~/openwrt$ make info
Current Target: "x86/64"
Current Revision: "r16554-1d4dea6d4f"
Default Packages: base-files ca-bundle dropbear fstools libc libgcc libustream-wolfssl logd mtd netifd opkg uci uclient-fetch urandom-seed urngd busybox procd partx-utils mkf2fs e2fsprogs kmod-button-hotplug dnsmasq firewall ip6tables iptables kmod-ipt-offload odhcp6c odhcpd-ipv6only ppp ppp-mod-pppoe
Available Profiles:

generic:
    Generic x86/64
    Packages: kmod-bnx2 kmod-e1000e kmod-e1000 kmod-forcedeth kmod-igb kmod-ixgbe kmod-r8169
    hasImageMetadata: 0
build@5d97695460c4:~/openwrt$ make help
Available Commands:
        help:   This help text
        info:   Show a list of available target profiles
        clean:  Remove images and temporary build files
        image:  Build an image (see below for more information).

Building images:
        By default 'make image' will create an image with the default
        target profile and package set. You can use the following parameters
        to change that:

        make image PROFILE="<profilename>" # override the default target profile
        make image PACKAGES="<pkg1> [<pkg2> [<pkg3> ...]]" # include extra packages
        make image FILES="<path>" # include extra files from <path>
        make image BIN_DIR="<path>" # alternative output directory for the images
        make image EXTRA_IMAGE_NAME="<string>" # Add this to the output image filename (sanitized)
        make image DISABLED_SERVICES="<svc1> [<svc2> [<svc3> ..]]" # Which services in /etc/init.d/ should be disabled
        make image ADD_LOCAL_KEY=1 # store locally generated signing key in built images

Print manifest:
        List "all" packages which get installed into the image.
        You can use the following parameters:

        make manifest PROFILE="<profilename>" # override the default target profile
        make manifest PACKAGES="<pkg1> [<pkg2> [<pkg3> ...]]" # include extra packages
        make manifest STRIP_ABI=1 # remove ABI version from printed package names
```
