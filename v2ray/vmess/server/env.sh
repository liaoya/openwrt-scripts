#!/bin/bash

_THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
_THIS_DIR=$(dirname "${_THIS_DIR}")

if [[ ! -f "${_THIS_DIR}/config.json" ]]; then
    #shellcheck disable=SC2002
    cat "${_THIS_DIR}/server-tpl.json" |
        jq ".inbounds[0].settings.clients[0].alterId=${V2RAY_ALTERID}" |
        jq ".inbounds[0].port=${V2RAY_PORT}" |
        jq ".inbounds[0].settings.clients[0].id=\"${V2RAY_UUID}\"" |
        jq -S '.' >"${_THIS_DIR}/config.json"
fi

unset -v _THIS_DIR
