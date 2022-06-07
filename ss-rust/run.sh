#!/bin/bash
#shellcheck disable=SC1091

set -aex

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")

function print_usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") options <clean|restart|start|stop> <client|kcp|server>
  -m, SIP003_PLUGIN_OPTS: sip003 plugin_opts. ${SIP003_PLUGIN:+The default is ${SIP003_PLUGIN}}
  -p, SIP003_PLUGIN: Shadowsocks sip003 plugin. ${SIP003_PLUGIN_OPTS:+The default is ${SIP003_PLUGIN_OPTS}}
EOF
}

if [[ -f "${ROOT_DIR}/pre.sh" ]]; then source "${ROOT_DIR}/pre.sh"; fi
SIP003_PLUGIN=${SIP003_PLUGIN:-}
SIP003_PLUGIN_OPTS=${SIP003_PLUGIN_OPTS:-}

while getopts ":hm:p:" opt; do
    case $opt in
    h)
        print_usage
        exit 0
        ;;
    m)
        SIP003_PLUGIN_OPTS=$OPTARG
        ;;
    p)
        SIP003_PLUGIN=$OPTARG
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
if [[ -n ${SIP003_PLUGIN} ]]; then
    export SIP003_PLUGIN
fi
if [[ -n ${SIP003_PLUGIN_OPTS} ]]; then
    export SIP003_PLUGIN_OPTS
fi

if [[ -f "${ROOT_DIR}/post.sh" ]]; then source "${ROOT_DIR}/post.sh"; fi
if [[ -f "$2/env.sh" ]]; then source "$2/env.sh"; fi
if [[ $1 == clean ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yml" down -v
    [[ -x "${2}/clean.sh" ]] && "${2}/clean.sh"
elif [[ $1 == restart ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yml" restart
elif [[ $1 == start ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yml" up -d
elif [[ $1 == stop ]]; then
    docker-compose -p "${PROJECT}" -f "${2}/docker-compose.yml" stop
else
    echo "Unknown opereation"
fi
