#!/bin/bash

#shellcheck disable=SC2034
BASE_URL="${BASE_URL_PREFIX}/releases/${VERSION}/targets/armvirt/64"

PACKAGES=""
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-mini -dnsmasq"
PACKAGES="${PACKAGES:+$PACKAGES }bash bind-dig ca-bundle ca-certificates coreutils-base64 curl dnsmasq-full fdisk file \
ip-full ipset iptables-mod-tproxy \
libpthread \
luci luci-theme-bootstrap luci-i18n-base-zh-cn luci-ssl \
nano tmux \
uci wpad"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-firewall-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }busybox diffutils openssl-util ipset dnsmasq-full iptables-mod-nat-extra wget ca-bundle ca-certificates libustream-openssl"
PACKAGES="${PACKAGES:+$PACKAGES }luci-i18n-vlmcsd-zh-cn luci-app-vlmcsd vlmcsd"
PACKAGES="${PACKAGES:+$PACKAGES }adbyby luci-app-adbyby-plus luci-i18n-adbyby-plus-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-ssr-plus shadowsocksr-libev-ssr-local v2ray pdnsd-alt"
if [[ ${VERSOIN} =~ 19.07 ]]; then
    PACKAGES="${PACKAGES:+$PACKAGES }-wpad-basic luci-compat luci-lib-ipkg uhttpd-mod-ubus"
fi

curl -sLO "${BASE_URL}/sha256sums"
SHA256_VALUE=$(grep imagebuilder sha256sums | cut -d' ' -f1)
IMAGE_BUILDER_FILENAME=$(grep imagebuilder sha256sums | cut -d'*' -f2)
SDK_FILENAME=$(grep openwrt-sdk sha256sums | cut -d'*' -f2)
SDK_DIR=$(basename -s .tar.xz "${SDK_FILENAME}")
SDK_DIR="${ROOT_DIR}/../sdk/${SDK_DIR}"
if [[ -f "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}" ]]; then
    if [[ $(sha256sum "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}" | cut -d' ' -f1) != "${SHA256_VALUE}" ]]; then
        rm -f "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}"
    fi
fi

if [[ ! -f "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}" ]]; then
    curl -sL "${BASE_URL}/${IMAGE_BUILDER_FILENAME}" -o "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}"
fi

pre_ops() {
    if [[ -d "${SDK_DIR}/bin/packages/x86_64" ]]; then
    #shellcheck disable=SC2164
        (cd "${SDK_DIR}/bin/packages/x86_64"; nohup python3 -m http.server 8080 1>/dev/null 2>&1 &)
        for repo in "src/gz reboot_sdk_base http://localhost:8080/base" \
                    "src/gz reboot_sdk_luci http://localhost:8080/luci" \
                    "src/gz reboot_sdk_package http://localhost:8080/packages"; do
            repo=$(echo "${repo}" | sed 's/\//\\\//g')
            sed -i "/telephony$/a ${repo}" repositories.conf
        done
    fi
}

post_ops() {
    pkill -9 python3
}
