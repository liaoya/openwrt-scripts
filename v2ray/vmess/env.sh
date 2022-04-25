#!/bin/bash

_THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
_THIS_DIR=$(dirname "${_THIS_DIR}")

if [[ -f "${_THIS_DIR}/.options" ]]; then
    V2RAY_ALTERID=$(grep -w alterid "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_PORT=$(grep -w port "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_SERVER=$(grep -w server "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_UUID=$(grep -w uuid "${_THIS_DIR}/.options" | cut -d"=" -f2)

    V2RAY_MKCP_ALTERID=$(grep -w mkcp_alterid "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MKCP_PASSWORD=$(grep -w mkcp_password "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MKCP_PORT=$(grep -w mkcp_port "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MKCP_UUID=$(grep -w mkcp_uuid "${_THIS_DIR}/.options" | cut -d"=" -f2)
fi

V2RAY_ALTERID=${V2RAY_ALTERID:-$((RANDOM % 70 + 30))}
V2RAY_PORT=${V2RAY_PORT:-$((RANDOM % 10000 + 30000))}
V2RAY_UUID=${V2RAY_UUID:-$(cat /proc/sys/kernel/random/uuid)}

V2RAY_MKCP_ALTERID=${V2RAY_MKCP_ALTERID:-$((RANDOM % 70 + 30))}
V2RAY_MKCP_PASSWORD=${V2RAY_MKCP_PASSWORD:-$(tr -cd '[:alnum:]' < /dev/urandom | fold -w20 | head -n1)}
V2RAY_MKCP_PORT=${V2RAY_MKCP_PORT:-$((RANDOM % 10000 + 30000))}
V2RAY_MKCP_UUID=${V2RAY_MKCP_UUID:-$(cat /proc/sys/kernel/random/uuid)}

{
    echo "alterid=${V2RAY_ALTERID}"
    echo "port=${V2RAY_PORT}"
    [[ -n ${V2RAY_SERVER} ]] && echo "server=${V2RAY_SERVER}"
    echo "uuid=${V2RAY_UUID}"

    echo "mkcp_alterid=${V2RAY_MKCP_ALTERID}"
    echo "mkcp_password=${V2RAY_MKCP_PASSWORD}"
    echo "mkcp_port=${V2RAY_MKCP_PORT}"
    echo "mkcp_uuid=${V2RAY_MKCP_UUID}"
} | sort | tee "${_THIS_DIR}/.options"

unset -v _THIS_DIR
export V2RAY_ALTERID V2RAY_PORT V2RAY_SERVER V2RAY_UUID
export V2RAY_MKCP_ALTERID V2RAY_MKCP_PASSWORD V2RAY_MKCP_PORT V2RAY_MKCP_UUID
