#!/bin/bash

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")
#shellcheck disable=SC1091
source "${THIS_DIR}/functions.sh"

function pre_ops() {
    configure_passwall
    configure_ssr_plus
    configure_v2ray
    configure_vssr_plus
}

if [[ -n ${OPENWRT_MIRROR_PATH} ]]; then
    #shellcheck disable=SC2034
    BASE_URL=${OPENWRT_MIRROR_PATH}/releases/${VERSION}/targets/ath79/nand
fi
