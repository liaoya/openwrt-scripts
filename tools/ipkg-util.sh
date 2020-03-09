#!/bin/bash

set -e

DEST=${DEST:-""}
OPERATION=${OPERATION:-"list"}
SRC=${SRC:-""}

print_usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -d, --dest, the dest directory for ipk
    -h, --help, show help
    -o, --operation, the value is copy or list
    -s, --src, the src directory of openwrt build
EOF
}

TEMP=$(getopt -o d:ho:s: --long dest:,help,operation:,src: -- "$@")
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -d|--dest)
            shift; DEST=$(readlink -f "$1") ;;
        -h|--help)
            print_usage; exit 0 ;;
        -o|--operation)
            shift; OPERATION=$1 ;;
        -s|--src)
            shift; SRC=$(readlink -f "$1") ;;
        --) shift; break ;;
        *)  print_usage; exit 1 ;;
    esac
    shift
done

if [[ ! -d "${SRC}/bin" ]]; then
    echo "${SRC} does not exist or is illegal"
    exit 1
fi

declare PACKAGES=(adbyby adguardhome autoreboot brook chinadns-ng coremark dns2socks \
    haproxy ipt2socks kcptun microsocks \
    passwall pdnsd ramfree shadowsocks simple-obfs smartdns srelay ssr-plus tcping trojan \
    v2ray vlmcsd)

if [[ ${OPERATION} == "list" ]]; then
    for name in "${PACKAGES[@]}"; do
        for pkg in $(find "${SRC}/bin" -iname "*$name*.ipk"); do ls -lh "${pkg}"; done
    done
elif [[ ${OPERATION} == "copy" ]]; then
    if [[ ! -d ${DEST} ]]; then
        echo "${DEST} does not exist"
        exit 1
    fi
    for name in "${PACKAGES[@]}"; do
        for pkg in $(find "${SRC}/bin" -iname "*$name*.ipk"); do cp -pr "${pkg}" "${DEST}"; done
    done
    (cd "${DEST}"; ipkg-make-index.sh . > Packages && gzip -9nc Packages > Packages.gz)
else
    echo "Unknown operaiton ${OPERATION}"
    exit 1
fi