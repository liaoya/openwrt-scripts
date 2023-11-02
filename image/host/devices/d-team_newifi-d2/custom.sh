#!/bin/bash
#shellcheck disable=SC1091,SC2034

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
if [[ -f "${THIS_DIR}/functions.sh" ]]; then
    source "${THIS_DIR}/functions.sh"
fi

if [[ -n ${OPENWRT_MIRROR_PATH} ]]; then
    BASE_URL="${OPENWRT_MIRROR_PATH}/releases/${VERSION}/targets/ramips/mt7621"
fi
