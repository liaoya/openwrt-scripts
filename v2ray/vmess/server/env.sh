#!/bin/bash

_THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
_THIS_DIR=$(dirname "${_THIS_DIR}")

export V2RAY_MKCP_PORT=${V2RAY[MKCP_PORT]}
export V2RAY_PORT=${V2RAY[PORT]}

if [[ ! -f "${_THIS_DIR}/docker-compose.yaml" ]]; then
    envsubst "$(env | sort | sed -e 's/=.*//' -e 's/^/\$/g')" <"${_THIS_DIR}/docker-compose.tpl.yaml" | tee "${_THIS_DIR}/docker-compose.yaml"
fi


if [[ ! -f "${_THIS_DIR}/config.json" ]]; then
    #shellcheck disable=SC2002
    cat "${_THIS_DIR}/server.tpl.json" |
        jq ".inbounds[0].port=${V2RAY[PORT]}" |
        jq ".inbounds[0].settings.clients[0].alterId=${V2RAY[ALTERID]}" |
        jq ".inbounds[0].settings.clients[0].id=\"${V2RAY[UUID]}\"" |
        jq ".inbounds[1].port=${V2RAY[MKCP_PORT]}" |
        jq ".inbounds[1].settings.clients[0].alterId=${V2RAY[MKCP_ALTERID]}" |
        jq ".inbounds[1].settings.clients[0].id=\"${V2RAY[MKCP_UUID]}\"" |
        jq ".inbounds[1].streamSettings.kcpSettings.downlinkCapacity=${V2RAY[MKCP_SERVER_DOWN_CAPACITY]}" |
        jq ".inbounds[1].streamSettings.kcpSettings.header.type=\"${V2RAY[MKCP_HEADER_TYPE]}\"" |
        jq ".inbounds[1].streamSettings.kcpSettings.seed=\"${V2RAY[MKCP_PASSWORD]}\"" |
        jq ".inbounds[1].streamSettings.kcpSettings.uplinkCapacity=${V2RAY[MKCP_SERVER_UP_CAPACITY]}" |
        jq -S '.' >"${_THIS_DIR}/config.json"
fi

unset -v _THIS_DIR
