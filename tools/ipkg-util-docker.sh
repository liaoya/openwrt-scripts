#!/bin/bash
#shellcheck disable=SC2206,SC2312

set -e

DEST=${DEST:-""}
OPERATION=${OPERATION:-"list"}
SRC=${SRC:-""}

function _print_help() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -d, --dest, the dest directory for ipk
    -h, --help, show help
    -o, --operation, the value is copy or list
    -s, --src, the src directory contain ipk package
EOF
}

TEMP=$(getopt -o d:ho:s: --long dest:,help,operation:,src: -- "$@")
eval set -- "${TEMP}"
while true; do
    case "$1" in
    -d | --dest)
        shift
        if [[ ! -d ${1} ]]; then
            mkdir -p "${1}"
        fi
        DEST=$(readlink -f "$1")
        ;;
    -h | --help)
        _print_help
        exit 0
        ;;
    -o | --operation)
        shift
        OPERATION=$1
        ;;
    -s | --src)
        shift
        SRC=$(readlink -f "$1")
        ;;
    --)
        shift
        break
        ;;
    *)
        _print_help
        exit 1
        ;;
    esac
    shift
done

if [[ ! -d "${SRC}/packages" ]]; then
    echo "${SRC} does not exist or is illegal"
    exit 1
fi

cd "${SRC}/packages"

if [[ ${OPERATION} == "list" ]]; then
    find . -iname "*.ipk" | grep -v "/base/" | grep -v "/luci/" | grep -v "/packages/" | grep -v "/routing/" | grep -v "/telephony/"
    find . \( -iname "*shadowsocks*.ipk" -o -iname "*smartdns*.ipk" -o -iname "*v2ray*.ipk" -o -iname "*xray*.ipk" \)
else
    while IFS= read -r _pkg; do
        cp "${_pkg}" "${DEST}"
    done < <(find . -iname "*.ipk" | grep -v "/base/" | grep -v "/luci/" | grep -v "/packages/" | grep -v "/routing/" | grep -v "/telephony/")
    while IFS= read -r _pkg; do
        cp "${_pkg}" "${DEST}"
    done < <(find . \( -iname "*shadowsocks*.ipk" -o -iname "*smartdns*.ipk" -o -iname "*v2ray*.ipk" -o -iname "*xray*.ipk" \) -print0)
fi
