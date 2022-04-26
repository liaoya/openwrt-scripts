#!/bin/bash

_THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
_THIS_DIR=$(dirname "${_THIS_DIR}")

if [[ ! -f "${_THIS_DIR}/config.json" ]]; then
    #shellcheck disable=SC2002
    cat "${_THIS_DIR}/client.tpl.json" |
        jq ".outbounds[2].settings.vnext[0].port=${V2RAY_PORT}" |
        jq ".outbounds[2].streamSettings.kcpSettings.seed=\"${V2RAY_MKCP_PASSWORD}\"" |
        jq ".outbounds[2].settings.vnext[0].address=\"${V2RAY_SERVER}\"" |
        jq ".outbounds[2].settings.vnext[0].users[0].id=\"${V2RAY_UUID}\"" |
        jq -S '.' >"${_THIS_DIR}/config.json"
    if [[ ${V2RAY_MUX_CONCURRENCY} -eq 0 ]]; then
        jq 'del(.outbounds[2].mux)' "${_THIS_DIR}/config.json" | sponge "${_THIS_DIR}/config.json"
    fi
fi

if [[ ! -f "${_THIS_DIR}/config-mkcp.json" ]]; then
    #shellcheck disable=SC2002
    cat "${_THIS_DIR}/client-mkcp.tpl.json" |
        jq ".outbounds[2].settings.vnext[0].port=${V2RAY_MKCP_PORT}" |
        jq ".outbounds[2].streamSettings.kcpSettings.downlinkCapacity=${V2RAY_MKCP_CLIENT_DOWN_CAPACITY}" |
        jq ".outbounds[2].streamSettings.kcpSettings.uplinkCapacity=${V2RAY_MKCP_CLIENT_UP_CAPACITY}" |
        jq ".outbounds[2].streamSettings.kcpSettings.seed=\"${V2RAY_MKCP_PASSWORD}\"" |
        jq ".outbounds[2].settings.vnext[0].address=\"${V2RAY_SERVER}\"" |
        jq ".outbounds[2].settings.vnext[0].users[0].id=\"${V2RAY_MKCP_UUID}\"" |
        jq -S '.' >"${_THIS_DIR}/config-mkcp.json"
    if [[ ${V2RAY_MUX_CONCURRENCY} -eq 0 ]]; then
        jq 'del(.outbounds[2].mux)' "${_THIS_DIR}/config-mkcp.json" | sponge "${_THIS_DIR}/config-mkcp.json"
    fi
fi

unset -v _THIS_DIR
