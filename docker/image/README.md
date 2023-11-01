# README

**Use <https://firmware-selector.openwrt.org> if you want a image with customize package.**

User OpenWRT docker image to build firmware

There're no image after `18.06.7` for `18.06` series

- `23.05`
  - `docker.io/openwrt/imagebuilder:x86-64-23.05.0`
  - `docker.io/openwrt/imagebuilder:armsr-armv8-23.05.0` (<https://openwrt.org/releases/23.05/notes-23.05.0>)
  - `docker.io/openwrt/imagebuilder:ath79-nand-23.05.0`
  - `docker.io/openwrt/imagebuilder:ramips-mt7621-23.05.0`
  - `docker.io/openwrt/imagebuilder:ramips-mt7620-23.05.0`
- `22.03`
  - `docker.io/openwrt/imagebuilder:x86-64-22.03.5`
  - `docker.io/openwrt/imagebuilder:armvirt-64-22.03.5`
  - `docker.io/openwrt/imagebuilder:ath79-nand-22.03.5`
  - `docker.io/openwrt/imagebuilder:ramips-mt7621-22.03.5`
  - `docker.io/openwrt/imagebuilder:ramips-mt7620-22.03.5`
- `21.02`
  - `docker.io/openwrt/imagebuilder:x86-64-21.02.7`
  - `docker.io/openwrt/imagebuilder:armvirt-64-21.02.7`
  - `docker.io/openwrt/imagebuilder:ath79-nand-21.02.7`
  - `docker.io/openwrt/imagebuilder:ramips-mt7621-21.02.7`
  - `docker.io/openwrt/imagebuilder:ramips-mt7620-21.02.7`
- `19.07`
  - `docker.io/openwrt/imagebuilder:x86-64-19.07.10`
- `18.06`
  - `docker.io/openwrtorg/imagebuilder:x86-64-18.06.7`

- `21.02`
  - `docker.io/immortalwrt/imagebuilder:x86-64-openwrt-21.02.7`
  - `docker.io/immortalwrt/imagebuilder:armvirt-64-openwrt-21.02.7`
  - `docker.io/immortalwrt/imagebuilder:ath79-nand-openwrt-21.02.7`
  - `docker.io/immortalwrt/imagebuilder:ramips-mt7621-openwrt-21.02.7`
  - `docker.io/immortalwrt/imagebuilder:ramips-mt7620-openwrt-21.02.7`

## OpenWRT 23.05

```bash
# The package must be declare external
unset -v PACKAGES
PACKAGES="-dnsmasq -wpad-mini -wpad-basic -wpad-basic-mbedtls \
dnsmasq-full wpad \
atop bash bind-dig bzip2 ca-bundle ca-certificates cfdisk coremark coreutils-base64 curl  dropbearconvert file fdisk gzip \
htop ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-compat luci-lib-ipkg \
luci-app-uhttpd luci-i18n-uhttpd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci-theme-bootstrap \
mtr nano tmux \
openssh-client openssh-client-utils openssh-keygen \
perl perlbase-cpan \
uci uhttpd-mod-ubus wget xz \
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
export PACKAGES

export OPENWRT_MIRROR_PATH=http://mirrors.cloud.tencent.com/openwrt
export OPENWRT_MIRROR_PATH=http://mirrors.aliyun.com/openwrt

bash -x build.sh -p x86-64 --dryrun

bash -x build.sh -p x86-64 -s 512 -c
bash -x build.sh -p ath79-nand -P netgear_wndr4300 -c
bash -x build.sh -p ramips-mt7621 -P d-team_newifi-d2
```

## 22.03

```bash
# The package must be declare external
unset -v PACKAGES
PACKAGES="-dnsmasq -wpad-mini -wpad-basic -wpad-basic-wolfssl \
dnsmasq-full wpad \
atop bash bind-dig bzip2 ca-bundle ca-certificates cfdisk coremark coreutils-base64 curl  dropbearconvert file fdisk gzip \
htop ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-compat luci-lib-ipkg \
luci-app-uhttpd luci-i18n-uhttpd-zh-cn \
luci-app-wol luci-i18n-wol-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci-theme-bootstrap \
mtr nano tmux \
openssh-client openssh-client-utils openssh-keygen \
perl perlbase-cpan \
uci uhttpd-mod-ubus wget xz \
"
PACKAGES="${PACKAGES:+$PACKAGES }coremark"
PACKAGES="${PACKAGES:+$PACKAGES }luci-theme-argon luci-app-argon-config luci-i18n-argon-config-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-ttyd luci-i18n-ttyd-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn vlmcsd"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-accesscontrol luci-i18n-accesscontrol-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-netdata luci-i18n-netdata-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-passwall luci-i18n-passwall-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-adbyby-plus luci-i18n-adbyby-plus-zh-cn"
export PACKAGES

export OPENWRT_MIRROR_PATH=http://mirrors.cloud.tencent.com/openwrt
export OPENWRT_MIRROR_PATH=http://mirrors.aliyun.com/openwrt

bash -x build.sh -p x86-64 -v 22.03.5

bash -x build.sh -p x86-64 -s 512 -v 22.03.5
bash -x build.sh -p ath79-nand -P netgear_wndr4300 -v 22.03.5
bash -x build.sh -p ramips-mt7621 -P d-team_newifi-d2 -v 22.03.5
```

## 21.02

```bash
unset -v PACKAGES
PACKAGES="${PACKAGES:+$PACKAGES }-dnsmasq -wpad-mini -wpad-basic -wpad-basic-wolfssl -wpad-basic-mbedtls -wpad-openssl dnsmasq-full wpad"
PACKAGES="${PACKAGES:+$PACKAGES }atop bash bind-dig coreutils-base64 curl diffutils dropbearconvert fdisk file \
ip-full ipset iptables-nft \
lscpu \
luci-app-wol luci-i18n-wol-zh-cn \
luci-app-accesscontrol luci-i18n-accesscontrol-zh-cn \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn \
luci luci-compat luci-lib-ipkg luci-theme-bootstrap \
mtr nano pciutils procps-ng-pkill tcpdump tmux \
uci wget"
PACKAGES="${PACKAGES:+$PACKAGES }coremark"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn vlmcsd"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-passwall luci-i18n-passwall-zh-cn"
export PACKAGES

OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://mirror.nju.edu.cn/immortalwrt}
bash build.sh -p armvirt-64 --distribution immortalwrt -v 21.02.7 --nocustomize
bash build.sh -p x86-64 --distribution immortalwrt -v 21.02.7
bash build.sh -p ath79-nand -P netgear_wndr4300 --distribution immortalwrt -v 21.02.7
bash build.sh -p ramips-mt7621 -P d-team_newifi-d2 --distribution immortalwrt -v 21.02.7
```

## Backup

The command to build

```bash
PACKAGES="-dnsmasq -wpad-mini -wpad-basic -wpad-basic-wolfssl dnsmasq-full wpad \
atop bash bind-dig coreutils-base64 curl diffutils dropbearconvert fdisk file \
ip-full ipset \
lscpu \
luci luci-theme-bootstrap \
nano pciutils procps-ng-pkill tcpdump tmux \
uci wget \
luci-app-vlmcsd vlmcsd"
platform=x86-64
profilename=generic
thirdparty=/work/openwrt/package/21.02/x64
version=21.02.7
major_version=$(echo "${version}" | cut -d. -f1,2)
bin_dir=${platform}-${profilename}-${version}-bin
[ -d ${bin_dir} ] || mkdir ${bin_dir}
docker run --rm -it -u "$(id -u):$(id -g)" \
    -e http_proxy="${http_proxy}" -e https_proxy="${https_proxy}" -e no_proxy="${no_proxy}" \
    -v "$(readlink -f ${bin_dir}):/home/build/openwrt/bin" \
    -v "$PWD/config/${major_version}/${platform}/${profilename}:/home/build/openwrt/custom" \
    -v "${thirdparty}:/home/build/openwrt/thirdparty" \
    docker.io/openwrtorg/imagebuilder:x86-64-21.02.7 bash -c "sed -i -e 's|https://downloads.openwrt.org|http://mirrors.ustc.edu.cn/openwrt|g' -e 's|http://downloads.openwrt.org|http://mirrors.ustc.edu.cn/openwrt|g' -e 's|# src custom file:///usr/src/openwrt/bin/x86/packages|src custom file:///home/build/openwrt/thirdparty|g' -e 's/^option check_signature$/# &/' repositories.conf; make image PROFILE=${profilename} PACKAGES='${PACKAGES}' FILES=/home/build/openwrt/custom"
```

```bash
cp ath79-nand-netgear_wndr4300-22.03.5-bin/targets/ath79/nand/*.manifest ath79-nand-netgear_wndr4300-22.03.5-bin/targets/ath79/nand/*.bin /work/openwrt/image/22.03/ath79-nand/

cp ramips-mt7620-phicomm_psg1208-22.03.5-bin/targets/ramips/mt7620/*.manifest ramips-mt7620-phicomm_psg1208-22.03.5-bin/targets/ramips/mt7620/*.bin /work/openwrt/image/22.03/ramips-mt7620/

cp ramips-mt7621-phicomm_k2p-22.03.5-bin/targets/ramips/mt7621/*.manifest ramips-mt7621-phicomm_k2p-22.03.5-bin/targets/ramips/mt7621/*.bin /work/openwrt/image/22.03/ramips-mt7621/

cp ramips-mt7621-d-team_newifi-d2-22.03.5-bin/targets/ramips/mt7621/*.manifest ramips-mt7621-d-team_newifi-d2-22.03.5-bin/targets/ramips/mt7621/*.bin /work/openwrt/image/22.03/ramips-mt7621/

cp x86-64-generic-22.03.5-bin/targets/x86/64/*.img x86-64-generic-22.03.5-bin/targets/x86/64/*.manifest /work/openwrt/image/22.03/x86-64/
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
