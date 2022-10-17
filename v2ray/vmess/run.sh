#!/bin/bash
#shellcheck disable=SC1091

set -aex

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
export ROOT_DIR

function print_usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") -h <clean|restart|start|stop> <client|server>
EOF
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

while getopts ":h" opt; do
    case $opt in
    h)
        print_usage
        exit 0
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

source "${ROOT_DIR}/env.sh"
if [[ -f "$2/env.sh" ]]; then source "$2/env.sh"; fi
if [[ $1 == clean ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yaml" down -v || true
    rm -f "${2}"/config.json "${2}"/config-*.json || true
    _delete_ufw_port "${V2RAY[PORT]}" "${V2RAY[MKCP_PORT]}"
    [[ -x "${2}/clean.sh" ]] && "${2}/clean.sh"
elif [[ $1 == restart ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yaml" restart
    _add_ufw_port "${V2RAY[PORT]}" "${V2RAY[MKCP_PORT]}"
elif [[ $1 == start ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yaml" up -d
    _add_ufw_port "${V2RAY[PORT]}" "${V2RAY[MKCP_PORT]}"
elif [[ $1 == stop ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yaml" stop
else
    echo "Unknown opereation"
fi
