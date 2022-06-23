#!/bin/bash

declare -A V2RAY
export V2RAY

function _read_param() {
    local _lower _upper
    _lower=${1,,}
    _upper=${1^^}
    if [[ -f "${ROOT_DIR}/.options" ]]; then
        V2RAY[${_upper}]=$(grep -i "^${_lower}=" "${ROOT_DIR}/.options" | cut -d'=' -f2-)
    fi
    if [[ -n ${!_upper} ]]; then
        V2RAY[${_upper}]=${V2RAY[${_upper}]:-${!_upper}}
    fi
    if [[ $# -gt 1 ]]; then
        V2RAY[${_upper}]=${V2RAY[${_upper}]:-${2}}
    fi
    V2RAY[${_upper}]=${V2RAY[${_upper}]:-""}
}

_read_param alterid $((RANDOM % 70 + 30))
_read_param port $((RANDOM % 10000 + 30000))
_read_param uuid "$(cat /proc/sys/kernel/random/uuid)"
_read_param mux_concurrency 4
_read_param server ""

_read_param mkcp_alterid $((RANDOM % 70 + 30))
_read_param mkcp_client_down_capacity 200
_read_param mkcp_client_up_capacity 50
_read_param mkcp_header_type none
_read_param mkcp_seed "$(tr -cd '[:alnum:]' </dev/urandom | fold -w15 | head -n1)"
# _read_param mkcp_seed ""
_read_param mkcp_port $((RANDOM % 10000 + 30000))
_read_param mkcp_server_down_capacity 200
_read_param mkcp_server_up_capacity 200
_read_param mkcp_uuid "$(cat /proc/sys/kernel/random/uuid)"

grep -e "^#" "${ROOT_DIR}/.options" | sponge "${ROOT_DIR}/.options"
for _key in "${!V2RAY[@]}"; do
    if [[ -n ${V2RAY[${_key}]} ]]; then
        echo "${_key,,}=${V2RAY[${_key}]}" >>"${ROOT_DIR}/.options"
    fi
done
sort "${ROOT_DIR}/.options" | sponge "${ROOT_DIR}/.options"
