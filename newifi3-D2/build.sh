#!/bin/bash
#shellcheck disable=SC2164

set -e -x

CLEAN=0
VERSION="18.06.1"

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

CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

PACKAGES=""
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-mini -dnsmasq"
PACKAGES="${PACKAGES:+$PACKAGES }bash bind-dig ca-bundle ca-certificates coreutils-base64 curl dnsmasq-full file \
ip-full ipset iptables-mod-tproxy \
libustream-openssl libpthread \
luci luci-theme-bootstrap luci-i18n-base-zh-cn \
uci wpad"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-firewall-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-adblock-zh-cn"
#PACKAGES="${PACKAGES:+$PACKAGES }kmod-macvlan luci-app-mwan3 luci-i18n-mwan3-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }ChinaDNS luci-app-chinadns dns-forwarder luci-app-dns-forwarder shadowsocks-libev luci-app-shadowsocks simple-obfs ShadowVPN luci-app-shadowvpn"
# for koolproxy
PACKAGES="${PACKAGES:+$PACKAGES }openssl-util ipset dnsmasq-full iptables-mod-nat-extra wget ca-bundle ca-certificates libustream-openssl"
# PACKAGES="${PACKAGES:+$PACKAGES }luci-app-minidlna luci-i18n-minidlna-zh-cn"

BASE_URL="https://downloads.openwrt.org/releases/${VERSION}/targets/ramips/mt7621"

curl -sLO "${BASE_URL}/sha256sums"
SHA256_VALUE=$(grep imagebuilder sha256sums | cut -d' ' -f1)
IMAGE_BUILDER_FILENAME=$(grep imagebuilder sha256sums | cut -d'*' -f2)
if [[ -f "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}" ]]; then
    if [[ $(sha256sum "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}" | cut -d' ' -f1) != "${SHA256_VALUE}" ]]; then
        rm -f "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}"
    fi
fi

if [[ ! -f "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}" ]]; then
    curl -sL "${BASE_URL}/${IMAGE_BUILDER_FILENAME}" -o "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}"
fi
#shellcheck disable=SC2046
if [[ $CLEAN -gt 0 && -d $(basename -s .tar.xz "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}") ]]; then rm -fr $(basename -s .tar.xz "${IMAGE_BUILDER_FILENAME}"); fi
tar -xf "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}"

#shellcheck disable=SC2046
cd $(basename -s .tar.xz "${IMAGE_BUILDER_FILENAME}")
for repo in "src/gz reboot_openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/mipsel_24kc" \
	    "src/gz reboot_openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci"; do
    repo=$(echo "${repo}" | sed 's/\//\\\//g')
    sed -i "/telephony$/a ${repo}" repositories.conf
done

[[ $CLEAN -gt 0 ]] && make clean
make -j "$(nproc)" image PROFILE=d-team_newifi-d2 PACKAGES="${PACKAGES}" FILES=../custom EXTRA_IMAGE_NAME=custom
