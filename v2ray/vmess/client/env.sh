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
fi

if [[ ! -f "${_THIS_DIR}/config-mkcp.json" ]]; then
    #shellcheck disable=SC2002
    cat "${_THIS_DIR}/client-mkcp.tpl.json" |
        jq ".outbounds[2].settings.vnext[0].port=${V2RAY_MKCP_PORT}" |
        jq ".outbounds[2].streamSettings.kcpSettings.seed=\"${V2RAY_MKCP_PASSWORD}\"" |
        jq ".outbounds[2].settings.vnext[0].address=\"${V2RAY_SERVER}\"" |
        jq ".outbounds[2].settings.vnext[0].users[0].id=\"${V2RAY_MKCP_UUID}\"" |
        jq -S '.' >"${_THIS_DIR}/config-mkcp.json"
fi

unset -v _THIS_DIR
