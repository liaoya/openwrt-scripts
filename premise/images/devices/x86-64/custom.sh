#!/bin/bash

if [[ -n ${OPENWRT_MIRROR_PATH} ]]; then
    #shellcheck disable=SC2034
    BASE_URL="${OPENWRT_MIRROR_PATH}/releases/${VERSION}/targets/x86/64"
fi

PACKAGES=${PACKAGES:-""}
_add_package -dnsmasq -wpad-mini -wpad-basic
if [[ ${VERSION} =~ 19.07 ]]; then
    _add_package luci-compat luci-lib-ipkg uhttpd-mod-ubus
fi
if [[ ${VERSION} =~ 21.02 ]] || [[ ${VERSION} =~ 22.03 ]]; then
    _add_package -wpad-basic-wolfssl
fi
_add_package kmod-dax kmod-dm
_add_package bind-dig ca-bundle ca-certificates coreutils-base64 curl diffutils dropbearconvert fdisk file
_add_package ip-full ipset iptables-mod-tproxy
_add_package luci luci-compat luci-lib-ipkg luci-theme-bootstrap
_add_package nano tmux

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
