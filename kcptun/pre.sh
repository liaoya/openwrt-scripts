#!/bin/bash

_this_dir=$(readlink -f "${BASH_SOURCE[0]}")
_this_dir=$(dirname "${_this_dir}")

export ALPINE_BASE=${ALPINE_IMAGE:-docker.io/library/alpine:3.16.2}

check_command jq upx

if [[ ! -f "${_this_dir}/client_linux_amd64" || ! -f "${_this_dir}/server_linux_amd64" ]]; then
    KCPTUN_VERSION=${KCPTUN_VERSION:-$(curl -sL https://api.github.com/repos/xtaci/kcptun/releases/latest | jq -r .tag_name)}
    check_param KCPTUN_VERSION
    curl -sL "https://github.com/xtaci/kcptun/releases/download/${KCPTUN_VERSION}/kcptun-linux-amd64-${KCPTUN_VERSION:1}.tar.gz" | tar -C "${_this_dir}" -zxf -
    check_file "${_this_dir}/client_linux_amd64" "${_this_dir}/server_linux_amd64"
else
    KCPTUN_VERSION=$("${_this_dir}/client_linux_amd64" -v | cut -d" " -f3)
    KCPTUN_VERSION="v${KCPTUN_VERSION}"
fi
upx "${_this_dir}/client_linux_amd64" "${_this_dir}/server_linux_amd64" || true
export KCPTUN_VERSION

_image_prefix=docker.io/yaekee

echo "${_this_dir}/Dockerfile.client"
if [[ ${DOCKERFILE} == "${_this_dir}/Dockerfile.client" ]]; then
    add_image "${_image_prefix}/kcptun-client:${KCPTUN_VERSION}"
elif [[ ${DOCKERFILE} == "${_this_dir}/Dockerfile.server" ]]; then
    add_image "${_image_prefix}/kcptun-server:${KCPTUN_VERSION}"
else
    echo "Unkonwn ${DOCKERFILE}"
    exit 1
fi
