#!/bin/bash

function _check_param() {
    while (($#)); do
        if [[ -z ${SHADOWSOCKS[$1]} ]]; then
            echo "\${SHADOWSOCKS[$1]} is required"
            exit 1
        fi
        shift 1
    done
}

function _read_param() {
    local _lower _upper
    _lower=${1,,}
    _upper=${1^^}
    if [[ -f "${ROOT_DIR}/.options" ]]; then
        SHADOWSOCKS[${_upper}]=$(grep -i "^${_lower}=" "${ROOT_DIR}/.options" | cut -d'=' -f2-)
    fi
    if [[ -n ${!_upper} ]]; then
        SHADOWSOCKS[${_upper}]=${SHADOWSOCKS[${_upper}]:-${!_upper}}
    fi
    if [[ $# -gt 1 ]]; then
        SHADOWSOCKS[${_upper}]=${SHADOWSOCKS[${_upper}]:-${2}}
    fi
    SHADOWSOCKS[${_upper}]=${SHADOWSOCKS[${_upper}]:-""}
}

# KCPTUN_VERSION=${KCPTUN_VERSION:-$(curl -s "https://api.github.com/repos/xtaci/kcptun/tags" | jq -r '.[0].name')}
KCPTUN_VERSION=${KCPTUN_VERSION:-v20210624}
SHADOWSOCKS_RUST_VERSION=${SHADOWSOCKS_RUST_VERSION:-$(curl -sL "https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')}
SHADOWSOCKS_RUST_VERSION=${SHADOWSOCKS_RUST_VERSION:-v1.14.3}
V2RAY_PLUGIN_VERSION=${V2RAY_PLUGIN_VERSION:-$(curl -s "https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest" | jq -r '.tag_name')}
V2RAY_PLUGIN_VERSION=${V2RAY_PLUGIN_VERSION:-v1.3.1}
XRAY_PLUGIN_VERSION=${XRAY_PLUGIN_VERSION:-$(curl -s "https://api.github.com/repos/teddysun/xray-plugin/tags" | jq -r '.[0].name')}
XRAY_PLUGIN_VERSION=${XRAY_PLUGIN_VERSION:-v1.5.7}

_read_param kcptun_port $((RANDOM % 30000 + 20000))
_read_param kcptun_version "${KCPTUN_VERSION}"
_read_param shadowsocks_password "$(tr -cd '[:alnum:]' </dev/urandom | fold -w30 | head -n1)"
_read_param shadowsocks_port $((RANDOM % 30000 + 10000))
_read_param shadowsocks_rust_version "${SHADOWSOCKS_RUST_VERSION}"
_read_param shadowsocks_server ""
_read_param sip003_plugin_opts ""
_read_param sip003_plugin ""
_read_param v2ray_plugin_version "${V2RAY_PLUGIN_VERSION}"
_read_param xray_plugin_version "${XRAY_PLUGIN_VERSION}"

if [[ -n ${SHADOWSOCKS[SIP003_PLUGIN]} ]]; then
    if [[ ${SHADOWSOCKS[SIP003_PLUGIN]} == xray-plugin ]] && [[ ! -x "${ROOT_DIR}/xray-plugin_linux_amd64" ]]; then
        curl -sL -o - "https://github.com/teddysun/xray-plugin/releases/download/${XRAY_PLUGIN_VERSION}/xray-plugin-linux-amd64-${XRAY_PLUGIN_VERSION}.tar.gz" | tar -C "${ROOT_DIR}" -I gzip -xf -
        chmod a+x "${ROOT_DIR}/xray-plugin_linux_amd64"
        sudo chown "$(id -un):$(id -gn)" "${ROOT_DIR}/xray-plugin_linux_amd64"
    elif [[ ${SHADOWSOCKS[SIP003_PLUGIN]} == v2ray-plugin ]] && [[ ! -x "${ROOT_DIR}/v2ray-plugin_linux_amd64" ]]; then
        curl -sL -o - "https://github.com/shadowsocks/v2ray-plugin/releases/download/${V2RAY_PLUGIN_VERSION}/v2ray-plugin-linux-amd64-${V2RAY_PLUGIN_VERSION}.tar.gz" | tar -C "${ROOT_DIR}" -I gzip -xf -
        chmod a+x "${ROOT_DIR}/v2ray-plugin_linux_amd64"
        sudo chown "$(id -un):$(id -gn)" "${ROOT_DIR}/v2ray-plugin_linux_amd64"
    fi
fi
_check_param KCPTUN_PORT KCPTUN_VERSION SHADOWSOCKS_PASSWORD SHADOWSOCKS_PORT SHADOWSOCKS_RUST_VERSION XRAY_PLUGIN_VERSION
export KCPTUN_PORT=${SHADOWSOCKS[KCPTUN_PORT]}
export KCPTUN_VERSION=${SHADOWSOCKS[KCPTUN_VERSION]}
export SHADOWSOCKS_PORT=${SHADOWSOCKS[SHADOWSOCKS_PORT]}
export SHADOWSOCKS_RUST_VERSION=${SHADOWSOCKS[SHADOWSOCKS_RUST_VERSION]}
