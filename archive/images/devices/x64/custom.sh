#!/bin/bash

if [[ -n ${BASE_URL_PREFIX} ]]; then
    #shellcheck disable=SC2034
    BASE_URL="${BASE_URL_PREFIX}/releases/${VERSION}/targets/x86/64"
fi

PACKAGES=${PACKAGES:-""}
if [[ ${VERSION} =~ 19.07 ]]; then
    PACKAGES="${PACKAGES:+$PACKAGES }-wpad-basic luci-compat luci-lib-ipkg uhttpd-mod-ubus"
fi

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
