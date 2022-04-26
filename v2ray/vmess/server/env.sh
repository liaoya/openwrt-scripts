#!/bin/bash

_THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
_THIS_DIR=$(dirname "${_THIS_DIR}")

if [[ ! -f "${_THIS_DIR}/config.json" ]]; then
    #shellcheck disable=SC2002
    cat "${_THIS_DIR}/server.tpl.json" |
        jq ".inbounds[0].settings.clients[0].alterId=${V2RAY_ALTERID}" |
        jq ".inbounds[0].port=${V2RAY_PORT}" |
        jq ".inbounds[0].settings.clients[0].id=\"${V2RAY_UUID}\"" |
        jq ".inbounds[1].settings.clients[0].alterId=${V2RAY_MKCP_ALTERID}" |
        jq ".inbounds[1].streamSettings.kcpSettings.downlinkCapacity=${V2RAY_MKCP_SERVER_DOWN_CAPACITY}" |
        jq ".inbounds[1].streamSettings.kcpSettings.seed=\"${V2RAY_MKCP_PASSWORD}\"" |
        jq ".inbounds[1].streamSettings.kcpSettings.uplinkCapacity=${V2RAY_MKCP_SERVER_UP_CAPACITY}" |
        jq ".inbounds[1].port=${V2RAY_MKCP_PORT}" |
        jq ".inbounds[1].settings.clients[0].id=\"${V2RAY_MKCP_UUID}\"" |
        jq -S '.' > "${_THIS_DIR}/config.json"
fi

unset -v _THIS_DIR
