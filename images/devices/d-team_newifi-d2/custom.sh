#!/bin/bash
#shellcheck disable=SC1091,SC2034

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
if [[ -f "${THIS_DIR}/functions.sh" ]]; then
    source "${THIS_DIR}/functions.sh"
fi

if [[ -n ${BASE_URL_PREFIX} ]]; then
    BASE_URL="${BASE_URL_PREFIX}/releases/${VERSION}/targets/ramips/mt7621"
fi

PACKAGES=${PACKAGES:-""}
if [[ ${VERSION} =~ 19.07 ]]; then
    PACKAGES="${PACKAGES:+$PACKAGES }-wpad-basic luci-compat luci-lib-ipkg uhttpd-mod-ubus"
fi
