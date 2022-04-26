#!/bin/bash

_THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
_THIS_DIR=$(dirname "${_THIS_DIR}")

if [[ -f "${_THIS_DIR}/.options" ]]; then
    V2RAY_ALTERID=$(grep -w alterid "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_PORT=$(grep -w port "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_SERVER=$(grep -w server "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_UUID=$(grep -w uuid "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MUX_CONCURRENCY=$(grep -w mux_concurrency "${_THIS_DIR}/.options" | cut -d"=" -f2)

    V2RAY_MKCP_ALTERID=$(grep -w mkcp_alterid "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MKCP_CLIENT_DOWN_CAPACITY=$(grep -w mkcp_client_down_capacity "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MKCP_CLIENT_UP_CAPACITY=$(grep -w mkcp_client_up_capacity "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MKCP_PASSWORD=$(grep -w mkcp_password "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MKCP_PORT=$(grep -w mkcp_port "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MKCP_SERVER_DOWN_CAPACITY=$(grep -w mkcp_server_down_capacity "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MKCP_SERVER_UP_CAPACITY=$(grep -w mkcp_server_up_capacity "${_THIS_DIR}/.options" | cut -d"=" -f2)
    V2RAY_MKCP_UUID=$(grep -w mkcp_uuid "${_THIS_DIR}/.options" | cut -d"=" -f2)
fi

V2RAY_ALTERID=${V2RAY_ALTERID:-$((RANDOM % 70 + 30))}
V2RAY_PORT=${V2RAY_PORT:-$((RANDOM % 10000 + 30000))}
V2RAY_UUID=${V2RAY_UUID:-$(cat /proc/sys/kernel/random/uuid)}
V2RAY_MUX_CONCURRENCY=${V2RAY_MUX_CONCURRENCY:-0}

V2RAY_MKCP_ALTERID=${V2RAY_MKCP_ALTERID:-$((RANDOM % 70 + 30))}
V2RAY_MKCP_CLIENT_DOWN_CAPACITY=${V2RAY_MKCP_CLIENT_DOWN_CAPACITY:-200}
V2RAY_MKCP_CLIENT_UP_CAPACITY=${V2RAY_MKCP_CLIENT_UP_CAPACITY:-50}
V2RAY_MKCP_PASSWORD=${V2RAY_MKCP_PASSWORD:-$(tr -cd '[:alnum:]' < /dev/urandom | fold -w20 | head -n1)}
V2RAY_MKCP_PORT=${V2RAY_MKCP_PORT:-$((RANDOM % 10000 + 30000))}
V2RAY_MKCP_SERVER_DOWN_CAPACITY=${V2RAY_MKCP_SERVER_DOWN_CAPACITY:-200}
V2RAY_MKCP_SERVER_UP_CAPACITY=${V2RAY_MKCP_SERVER_UP_CAPACITY:-200}
V2RAY_MKCP_UUID=${V2RAY_MKCP_UUID:-$(cat /proc/sys/kernel/random/uuid)}
V2RAY_MKCP_PASSWORD=""

{
    echo "alterid=${V2RAY_ALTERID}"
    echo "port=${V2RAY_PORT}"
    [[ -n ${V2RAY_SERVER} ]] && echo "server=${V2RAY_SERVER}"
    echo "uuid=${V2RAY_UUID}"
    echo "mux_concurrency=${V2RAY_MUX_CONCURRENCY}"

    echo "mkcp_alterid=${V2RAY_MKCP_ALTERID}"
    echo "mkcp_client_down_capacity=${V2RAY_MKCP_CLIENT_DOWN_CAPACITY}"
    echo "mkcp_client_up_capacity=${V2RAY_MKCP_CLIENT_UP_CAPACITY}"
    echo "mkcp_password=${V2RAY_MKCP_PASSWORD}"
    echo "mkcp_port=${V2RAY_MKCP_PORT}"
    echo "mkcp_server_down_capacity=${V2RAY_MKCP_SERVER_DOWN_CAPACITY}"
    echo "mkcp_server_up_capacity=${V2RAY_MKCP_SERVER_UP_CAPACITY}"
    echo "mkcp_uuid=${V2RAY_MKCP_UUID}"
} | sort | tee "${_THIS_DIR}/.options"

unset -v _THIS_DIR
export V2RAY_ALTERID V2RAY_PORT V2RAY_SERVER V2RAY_UUID V2RAY_MUX_CONCURRENCY
export V2RAY_MKCP_ALTERID V2RAY_MKCP_CLIENT_DOWN_CAPACITY V2RAY_MKCP_CLIENT_UP_CAPACITY V2RAY_MKCP_PASSWORD V2RAY_MKCP_PORT V2RAY_MKCP_SERVER_DOWN_CAPACITY V2RAY_MKCP_SERVER_UP_CAPACITY V2RAY_MKCP_UUID
