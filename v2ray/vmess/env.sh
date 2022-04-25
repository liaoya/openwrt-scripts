#!/bin/bash

_THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
_THIS_DIR=$(dirname "${_THIS_DIR}")

if [[ -f "${_THIS_DIR}/.options" ]]; then
    V2RAY_ALTERID=$(grep alterid "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_PORT=$(grep port "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_SERVER=$(grep server "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_UUID=$(grep uuid "${_THIS_DIR}/.options" | cut -d"=" -f2)
else
    V2RAY_ALTERID=${V2RAY_ALTERID:-$((RANDOM % 70 + 30))}
    V2RAY_PORT=${V2RAY_PORT:-$((RANDOM % 10000 + 30000))}
    V2RAY_UUID=${V2RAY_UUID:-$(cat /proc/sys/kernel/random/uuid)}
    {
        echo "alterid=${V2RAY_ALTERID}"
        echo "port=${V2RAY_PORT}"
        echo "uuid=${V2RAY_UUID}"
    } >>"${_THIS_DIR}/.options"
    if [[ -f "${_THIS_DIR}/config.json" ]]; then rm -f "${_THIS_DIR}/config.json"; fi
fi

unset -v _THIS_DIR
export V2RAY_ALTERID V2RAY_PORT V2RAY_SERVER V2RAY_UUID
