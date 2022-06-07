#!/bin/bash

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")

{
    echo "kcptun_port=${KCPTUN_PORT}"
    echo "kcptun_version=${KCPTUN_VERSION}"
    echo "shadowsocks_password=${SHADOWSOCKS_PASSWORD}"
    echo "shadowsocks_port=${SHADOWSOCKS_PORT}"
    echo "shadowsocks_rust_version=${SHADOWSOCKS_RUST_VERSION}"
    [[ -n ${SHADOWSOCKS_SERVER} ]] && echo "shadowsocks_server=${SHADOWSOCKS_SERVER}"
    [[ -n ${SIP003_PLUGIN} ]] && echo "sip003_plugin=${SIP003_PLUGIN}"
    [[ -n ${SIP003_PLUGIN_OPTS} ]] && echo "sip003_plugin_opts=${SIP003_PLUGIN_OPTS}"
    echo "xray_plugin_version=${XRAY_PLUGIN_VERSION}"
} | sort | tee "${THIS_DIR}/.options"

unset -v THIS_DIR
