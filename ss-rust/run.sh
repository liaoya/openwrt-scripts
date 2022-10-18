#!/bin/bash
#shellcheck disable=SC1091

set -ae

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
export ROOT_DIR

function _check_command() {
    while (($#)); do
        if [[ -z $(command -v "${1}") ]]; then
            echo "Command ${1} is required"
            return 1
        fi
        shift
    done
}

function _add_ufw_port() {
    while (($#)); do
        if ! sudo ufw status numbered | sed '1,4d' | sed -s 's/\[ /\[/g' | tr -d '[]' | cut -d' ' -f2 | grep -s -q -w "${1}"; then
            sudo ufw allow "${1}"
        fi
        shift
    done
}

function _delete_ufw_port() {
    while (($#)); do
        while IFS= read -r num; do
            echo "y" | sudo ufw delete "${num}"
        done < <(sudo ufw status numbered | sed '1,4d' | sed -s 's/\[ /\[/g' | tr -d '[]' | cut -d' ' -f1,2 | grep -w "${1}" | tac | cut -d' ' -f1)
        shift
    done
}

function enable_trace() {
    set -x
    export PS4='+(${BASH_SOURCE[0]}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
}

function print_usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") options <clean|restart|start|stop> <client|kcp|server>
  -m, SIP003_PLUGIN_OPTS: sip003 plugin_opts. ${SHADOWSOCKS[SIP003_PLUGIN]:+The default is ${SHADOWSOCKS[SIP003_PLUGIN_OPTS]}}
  -p, SIP003_PLUGIN: Shadowsocks sip003 plugin. ${SHADOWSOCKS[SIP003_PLUGIN_OPTS]:+The default is ${SHADOWSOCKS[SIP003_PLUGIN]}}
  -v, VERBOSE
EOF
}

_check_command docker docker-compose jq yq

declare -A SHADOWSOCKS
export SHADOWSOCKS

if [[ -f "${ROOT_DIR}/pre.sh" ]]; then source "${ROOT_DIR}/pre.sh"; fi

while getopts ":hvm:p:" opt; do
    case $opt in
    h)
        print_usage
        exit 0
        ;;
    v)
        enable_trace
        ;;
    m)
        SHADOWSOCKS[SIP003_PLUGIN_OPTS]=$OPTARG
        ;;
    p)
        SHADOWSOCKS[SIP003_PLUGIN]=$OPTARG
        ;;
    \?)
        print_usage
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

if [[ $# -ne 2 ]] || [[ $1 != clean && $1 != restart && $1 != start && $1 != stop ]] || [[ ! -d $2 ]]; then
    print_usage
    exit 1
fi

PROJECT=$(basename "${ROOT_DIR}")

if [[ -f "${ROOT_DIR}/post.sh" ]]; then source "${ROOT_DIR}/post.sh"; fi
if [[ -f "$2/env.sh" ]]; then source "$2/env.sh"; fi

if [[ $1 == clean ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yaml" down -v
    if [[ $2 == server ]]; then
        _delete_ufw_port "${SHADOWSOCKS[KCPTUN_PORT]}" "${SHADOWSOCKS[SHADOWSOCKS_PORT]}"
    fi
    [[ -x "${2}/clean.sh" ]] && source "${2}/clean.sh"
elif [[ $1 == restart ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yaml" restart
    if [[ $2 == server ]]; then
        _add_ufw_port "${SHADOWSOCKS[KCPTUN_PORT]}" "${SHADOWSOCKS[SHADOWSOCKS_PORT]}"
    fi
elif [[ $1 == start ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yaml" up -d
    if [[ $2 == server ]]; then
        _add_ufw_port "${SHADOWSOCKS[KCPTUN_PORT]}" "${SHADOWSOCKS[SHADOWSOCKS_PORT]}"
    fi
elif [[ $1 == stop ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yaml" stop
else
    echo "Unknown opereation"
fi
