#!/bin/bash

_THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
_THIS_DIR=$(dirname "${_THIS_DIR}")

if [[ ! -f "${_THIS_DIR}/docker-compose.yaml" ]]; then
    envsubst "$(env | sort | sed -e 's/=.*//' -e 's/^/\$/g')" <"${_THIS_DIR}/docker-compose.tpl.yaml" | tee "${_THIS_DIR}/docker-compose.yaml"
    if [[ -n ${SHADOWSOCKS[SIP003_PLUGIN]} ]]; then
        if [[ ${SHADOWSOCKS[SIP003_PLUGIN]} == "xray-plugin" && -x "${ROOT_DIR}/xray-plugin_linux_amd64" ]]; then
            yq '.services.ssserver-rust.volumes += "../xray-plugin_linux_amd64:/usr/local/bin/xray-plugin"' "${_THIS_DIR}/docker-compose.yaml" | sponge "${_THIS_DIR}/docker-compose.yaml"
        fi
    fi
fi

if [[ ! -f "${_THIS_DIR}/ssserver-rust.json" ]]; then
    jq -S ".password=${SHADOWSOCKS[SHADOWSOCKS_PASSWORD]}" "${_THIS_DIR}/ssserver-rust.tpl.json" | tee "${_THIS_DIR}/ssserver-rust.json"
    if [[ -n ${SHADOWSOCKS[SIP003_PLUGIN]} ]]; then
        jq --arg value "${SHADOWSOCKS[SIP003_PLUGIN]}" '. + {plugin: $value}' "${_THIS_DIR}/ssserver-rust.json" |
            jq --arg value "${SHADOWSOCKS[SIP003_PLUGIN_OPTS]}" '. + {plugin_opts: $value}' |
            jq -S . | sponge "${_THIS_DIR}/ssserver-rust.json"
    fi
fi

unset -v _THIS_DIR
