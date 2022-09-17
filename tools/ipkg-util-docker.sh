#!/bin/bash
#shellcheck disable=SC2206,SC2312

set -e

DEST=${DEST:-""}
OPERATION=${OPERATION:-"list"}
SRC=${SRC:-""}

function _print_help() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS] <list|copy> <SRC> [DEST]
OPTIONS
    -h, --help, show help
EOF
}

while getopts :h OPTION; do
    case $OPTION in
    h)
        _print_help
        exit 0
        ;;
    *)
        _print_help
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

if [[ ${1} != list && ${1} != copy ]]; then
    _print_help
    exit 1
fi
OPERATION=${1}
shift

if [[ ! -d "${1}/packages" ]]; then
    echo "${1} does not exist or is illegal"
    exit 1
fi
SRC=${1}
shift

if [[ ${OPERATION} == "copy" ]]; then
    if [[ $# -eq 0 ]]; then
        _print_help
        exit 1
    fi
    DEST=${1}
    if [[ ! -d "${DEST}" ]]; then
        mkdir -p "${DEST}"
    fi
fi

#shellcheck disable=SC2086
cd "${SRC}/packages/$(ls -1 ${SRC}/packages)"

if [[ ${OPERATION} == "list" ]]; then
    find . -iname "*.ipk" | grep -v "/base/" | grep -v "/luci/" | grep -v "/packages/" | grep -v "/routing/" | grep -v "/telephony/"
    find . \( -iname "*coremark*.ipk" -o -iname "*shadowsocks*.ipk" -o -iname "*smartdns*.ipk" -o -iname "*v2ray*.ipk" -o -iname "*xray*.ipk" \)
elif [[ ${OPERATION} == "copy" ]]; then
    while IFS= read -r _pkg; do
        cp "${_pkg}" "${DEST}"
    done < <(find . -iname "*.ipk" | grep -v "/base/" | grep -v "/luci/" | grep -v "/packages/" | grep -v "/routing/" | grep -v "/telephony/")
    while IFS= read -r -d '' _pkg; do
        cp "${_pkg}" "${DEST}"
    done < <(find . \( -iname "*coremark*.ipk" -o -iname "*shadowsocks*.ipk" -o -iname "*smartdns*.ipk" -o -iname "*v2ray*.ipk" -o -iname "*xray*.ipk" \) -print0)
    if command -v ipkg-make-index.sh; then
        pushd "${DEST}" || exit 1
        ipkg-make-index.sh . >Packages && gzip -9nc Packages >Packages.gz
    fi
else
    echo "Unkonwn ${OPERATION}"
    exit 1
fi
