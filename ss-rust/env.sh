#!/bin/bash

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

function _check_param() {
    while (($#)); do
        if [[ -z ${!1} ]]; then
            echo "\${$1} is required"
            exit 1
        fi
        shift 1
    done
}

if [[ -f "${THIS_DIR}/.options" ]]; then
    KCPTUN_VERSION=$(grep -e "^kcptun_version=" "${THIS_DIR}/.options" | cut -d"=" -f2)
    SHADOWSOCKS_RUST_VERSION=$(grep -e "^shadowsocks_rust_version=" "${THIS_DIR}/.options" | cut -d"=" -f2)

    KCPTUN_PORT=$(grep -e "^kcptun_port=" "${THIS_DIR}/.options" | cut -d"=" -f2)
    SHADOWSOCK_PASSWORD=$(grep -e "^password=" "${THIS_DIR}/.options" | cut -d"=" -f2)
    SHADOWSOCK_PORT=$(grep -e "^port=" "${THIS_DIR}/.options" | cut -d"=" -f2)
    if grep -s -q -e "^shadowsock_server=" "${THIS_DIR}/.options"; then
        SHADOWSOCK_SERVER=$(grep -e "^shadowsock_server=" "${THIS_DIR}/.options" | cut -d"=" -f2)
    fi
else
    # KCPTUN_VERSION=${KCPTUN_VERSION:-$(curl -s "https://api.github.com/repos/xtaci/kcptun/tags" | jq -r '.[0].name')}
    KCPTUN_VERSION=${KCPTUN_VERSION:-v20210624}
    export KCPTUN_VERSION
    SHADOWSOCKS_RUST_VERSION=${SHADOWSOCKS_RUST_VERSION:-$(curl -sL "https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')}
    SHADOWSOCKS_RUST_VERSION=${SHADOWSOCKS_RUST_VERSION:-v1.12.4}
    export SHADOWSOCKS_RUST_VERSION

    KCPTUN_PORT=${KCPTUN_PORT:-$((RANDOM % 30000 + 10000))}
    SHADOWSOCK_PASSWORD=${SHADOWSOCK_PASSWORD:-$(tr -cd '[:alnum:]' </dev/urandom | fold -w30 | head -n1)}
    SHADOWSOCK_PORT=${SHADOWSOCK_PORT:-$((RANDOM % 30000 + 10000))}
    {
        echo "kcptun_version=${KCPTUN_VERSION}"
        echo "shadowsocks_rust_version=${SHADOWSOCKS_RUST_VERSION}"
        echo "kcptun_port=${KCPTUN_PORT}"
        echo "password=${SHADOWSOCK_PASSWORD}"
        echo "port=${SHADOWSOCK_PORT}"
        [[ -n ${SHADOWSOCK_SERVER} ]] && echo "shadowsock_server=${SHADOWSOCK_SERVER}"
    } | sort | tee "${THIS_DIR}/.options"
fi
_check_param KCPTUN_PORT KCPTUN_VERSION SHADOWSOCK_PASSWORD SHADOWSOCK_PORT SHADOWSOCKS_RUST_VERSION
export KCPTUN_PORT KCPTUN_VERSION SHADOWSOCK_PASSWORD SHADOWSOCK_PORT SHADOWSOCKS_RUST_VERSION
