#!/bin/bash

_this_dir=$(readlink -f "${BASH_SOURCE[0]}")
_this_dir=$(dirname "${THIS_DIR}")

for _item in "${_this_dir}"/*.sh; do
    if [[ ! -x "${_item}" ]]; then
        chmod a+x "${_item}"
    fi
done

ALPINE_IMAGE=${ALPINE_IMAGE:-docker.io/library/alpine:3.15.10@sha256:36ca6d117c068378d5461b959d019eabe8877770f13e11e54a5ce9f3827a7e72}
concat_docker_build_arg ALPINE_IMAGE
SQUID_VERSION=${SQUID_VERSION:-5.2-r0}
_IMAGE_PREFIX=docker.io/yaekee

add_image "${_IMAGE_PREFIX}/squid:${SQUID_VERSION}"
add_image "${_IMAGE_PREFIX}/squid:latest"
