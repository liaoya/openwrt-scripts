#!/bin/bash
#shellcheck disable=SC2164

set -e -x

CLEAN=0

TEMP=$(getopt -o c:: --long clean:: -- "$@")
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -c|--clean)
            CLEAN=1 ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Usage [-v|--version] <openwrt version> [-c|--clean]" ; exit 1 ;;
    esac
done

CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

PACKAGES="-wpad-mini -dnsmasq \
bash \
ca-bundle ca-certificates coreutils-base64 curl libustream-openssl \
bind-dig dnsmasq-full \
file \
ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-app-firewall luci-theme-bootstrap luci-app-adblock \
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-adblock-zh-cn \
uci \
wpad \
ChinaDNS luci-app-chinadns dns-forwarder luci-app-dns-forwarder shadowsocks-libev luci-app-shadowsocks simple-obfs ShadowVPN luci-app-shadowvpn \
"

PACKAGES="${PACKAGES} kmod-macvlan luci-app-mwan3 luci-i18n-mwan3-zh-cn"
# for koolproxy
PACKAGES="${PACKAGES} openssl-util ipset dnsmasq-full diffutils iptables-mod-nat-extra wget ca-bundle ca-certificates libustream-openssl"
# PACKAGES="${PACKAGES} luci-app-minidlna luci-i18n-minidlna-zh-cn"

BASE_URL=https://downloads.openwrt.org/releases/18.06.1/targets/ramips/mt7621

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
