#!/bin/bash

_this_dir=$(readlink -f "${BASH_SOURCE[0]}")
_this_dir=$(dirname "${_this_dir}")

for _item in "${_this_dir}"/*.sh; do
    if [[ ! -x "${_item}" ]]; then
        chmod a+x "${_item}"
    fi
done

SQUID_VERSION=${SQUID_VERSION:-5.2-r0}
_image_prefix=docker.io/yaekee

add_image "${_image_prefix}/squid:${SQUID_VERSION}"
add_image "${_image_prefix}/squid:latest"
