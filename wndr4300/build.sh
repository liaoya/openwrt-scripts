#!/bin/bash
#shellcheck disable=SC2164

set -e -x

VERSION="17.01.6"
CLEAN=0

TEMP=$(getopt -o v:c:: --long version:,clean:: -- "$@")
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -v|--version)
            VERSION=$2 ; shift 2 ;;
        -c|--clean)
            CLEAN=1 ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Usage [-v|--version] <openwrt version> [-c|--clean]" ; exit 1 ;;
    esac
done

PACKAGES="-wpad-mini -dnsmasq \
bash \
ca-bundle ca-certificates coreutils-base64 curl \
dnsmasq-full \
file \
ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-app-firewall luci-theme-bootstrap luci-app-adblock \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-adblock-zh-cn \
uci \
wpad \
ChinaDNS luci-app-chinadns dns-forwarder luci-app-dns-forwarder shadowsocks-libev luci-app-shadowsocks simple-obfs ShadowVPN luci-app-shadowvpn \
vlmcsd \
"

curl -sLO https://downloads.openwrt.org/releases/${VERSION}/targets/ar71xx/nand/sha256sums
SHA256_VALUE=$(grep imagebuilder sha256sums | cut -d' ' -f1)
IMAGE_BUILDER_FILENAME=$(grep imagebuilder sha256sums | cut -d'*' -f2)
if [[ -f "${IMAGE_BUILDER_FILENAME}" ]]; then
    if [[ $(sha256sum "${IMAGE_BUILDER_FILENAME}" | cut -d' ' -f1) != "${SHA256_VALUE}" ]]; then
        rm -f "${IMAGE_BUILDER_FILENAME}"
    fi
fi
if [[ ! -f "${IMAGE_BUILDER_FILENAME}" ]]; then
    curl -sLO "https://downloads.openwrt.org/releases/${VERSION}/targets/ar71xx/nand/${IMAGE_BUILDER_FILENAME}"
fi
tar -xf "${IMAGE_BUILDER_FILENAME}"
#shellcheck disable=SC2046
if [[ $CLEAN -gt 0 && -d $(basename -s .tar.xz "${IMAGE_BUILDER_FILENAME}") ]]; then rm -fr $(basename -s .tar.xz "${IMAGE_BUILDER_FILENAME}"); fi 

#wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > custom/etc/chinadns_chnroute.txt

#shellcheck disable=SC2046
cd $(basename -s .tar.xz "${IMAGE_BUILDER_FILENAME}")
sed -i  s/'23552k(ubi),25600k@0x6c0000(firmware)'/'120832k(ubi),122880k@0x6c0000(firmware)'/ target/linux/ar71xx/image/legacy.mk
for repo in "src/gz reboot_openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/mips_24kc" \
	    "src/gz reboot_openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci" \
	    "src/gz reboot_vlmcsd http://cokebar.github.io/openwrt-vlmcsd/LEDE"; do
    repo=$(echo "${repo}" | sed 's/\//\\\//g')
    sed -i "/telephony$/a ${repo}" repositories.conf
done

[[ $CLEAN -gt 0 ]] && make clean
make -j "$(nproc)" image PROFILE=WNDR4300V1 PACKAGES="${PACKAGES}" FILES=../custom EXTRA_IMAGE_NAME=custom
