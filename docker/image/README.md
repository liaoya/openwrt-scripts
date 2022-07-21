# README

User OpenWRT docker image to build firmware

There're no image after `18.06.7` for `18.06` series

- `docker.io/openwrtorg/imagebuilder:x86-64-21.02.3`
- `docker.io/openwrtorg/imagebuilder:armvirt-64-21.02.3`
- `docker.io/openwrtorg/imagebuilder:ath79-nand-21.02.3`
- `docker.io/openwrtorg/imagebuilder:ramips-mt7621-21.02.3`
- `docker.io/openwrtorg/imagebuilder:x86-64-19.07.8`
- `docker.io/openwrtorg/imagebuilder:x86-64-18.06.7`

```bash
# The package must be declare external
PACKAGES="${PACKAGES:+$PACKAGES }-dnsmasq -wpad-mini -wpad-basic -wpad-basic-wolfssl dnsmasq-full wpad"
PACKAGES="${PACKAGES:+$PACKAGES }atop bash bind-dig coreutils-base64 curl diffutils dropbearconvert fdisk file \
ip-full ipset \
lscpu \
luci luci-theme-bootstrap \
nano pciutils procps-ng-pkill tcpdump tmux \
uci wget"
export PACKAGES

bash -x build.sh -p x86-64 -v 21.02.3 --dryrun

bash -x build.sh -p x86-64 -v 21.02.3 -c
bash -x build.sh -p ath79-nand -P netgear_wndr4300 -v 21.02.3 -c
bash -x build.sh -p ramips-mt7621 -P d-team_newifi-d2 -v 21.02.3 -c

PACKAGES="${PACKAGES:+$PACKAGES }luci-app-vlmcsd vlmcsd"
bash -x build.sh -p x86-64 -v 21.02.3 -t /work/openwrt/package/21.02/x64 -c
bash -x build.sh -p ath79-nand -P netgear_wndr4300 -v 21.02.3 -t /work/openwrt/package/21.02/ath79 -c
bash -x build.sh -p ramips-mt7621 -P d-team_newifi-d2 -v 21.02.3 -t /work/openwrt/package/21.02/mt7621 -c

bash -x build.sh -p ramips-mt7621 -P d-team_newifi-d2 -v 19.07.9 -c
bash -x build.sh -p ath79-nand -P netgear_wndr4300 -v 19.07.9 -c
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
version=21.02.3
major_version=$(echo "${version}" | cut -d. -f1,2)
bin_dir=${platform}-${profilename}-${version}-bin
[ -d ${bin_dir} ] || mkdir ${bin_dir}
docker run --rm -it -u "$(id -u):$(id -g)" \
    -e http_proxy="${http_proxy}" -e https_proxy="${https_proxy}" -e no_proxy="${no_proxy}" \
    -v "$(readlink -f ${bin_dir}):/home/build/openwrt/bin" \
    -v "$PWD/config/${major_version}/${platform}/${profilename}:/home/build/openwrt/custom" \
    -v "${thirdparty}:/home/build/openwrt/thirdparty" \
    docker.io/openwrtorg/imagebuilder:x86-64-21.02.3 bash -c "sed -i -e 's|https://downloads.openwrt.org|http://mirrors.ustc.edu.cn/openwrt|g' -e 's|http://downloads.openwrt.org|http://mirrors.ustc.edu.cn/openwrt|g' -e 's|# src custom file:///usr/src/openwrt/bin/x86/packages|src custom file:///home/build/openwrt/thirdparty|g' -e 's/^option check_signature$/# &/' repositories.conf; make image PROFILE=${profilename} PACKAGES='${PACKAGES}' FILES=/home/build/openwrt/custom"
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
