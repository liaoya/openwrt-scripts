#!/bin/bash

_THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
_THIS_DIR=$(dirname "${_THIS_DIR}")

declare -A V2RAY
export V2RAY

function _read_param() {
    local _default _name
    _name=$1
    _default=$2
    V2RAY[${_name}]=$(grep -w -i "${_name,,}" "${_THIS_DIR}/.options" | cut -d'=' -f2)
    V2RAY[${_name}]=${V2RAY[${_name}]:-${_default}}
}

_read_param ALTERID $((RANDOM % 70 + 30))
_read_param PORT $((RANDOM % 10000 + 30000))
_read_param UUID "$(cat /proc/sys/kernel/random/uuid)"
_read_param MUX_CONCURRENCY 4
_read_param SERVER 155.94.149.79

_read_param MKCP_ALTERID $((RANDOM % 70 + 30))
_read_param MKCP_CLIENT_DOWN_CAPACITY 200
_read_param MKCP_CLIENT_UP_CAPACITY 50
_read_param MKCP_PASSWORD "$(tr -cd '[:alnum:]' < /dev/urandom | fold -w20 | head -n1)"
_read_param MKCP_PORT $((RANDOM % 10000 + 30000))
_read_param MKCP_SERVER_DOWN_CAPACITY 200
_read_param MKCP_SERVER_UP_CAPACITY 200
_read_param MKCP_UUID "$(cat /proc/sys/kernel/random/uuid)"
_read_param MKCP_PASSWORD ""

rm -f "${_THIS_DIR}/.options"

for _key in "${!V2RAY[@]}"; do echo "${_key^^}=${V2RAY[${_key}]}" >> "${_THIS_DIR}/.options"; done
sort "${_THIS_DIR}/.options" | sponge "${_THIS_DIR}/.options"

unset -v _THIS_DIR
