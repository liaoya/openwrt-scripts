#!/bin/bash

set -a -e -x

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

DEVICE=""
VERSION="18.06.4"
CLEAN=0

print_usage() {
    echo "Usage [-d|--device] <device name> [-V|--version] <openwrt version> [-c|--clean] [-h|--help]"
}

TEMP=$(getopt -o d:v:c::h:: --long device:,version:,clean::,help:: -- "$@")
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -d|--device)
            DEVICE=$2; shift 2 ;;
        -V|--version)
#shellcheck disable=SC2034
            VERSION=$2; shift 2 ;;
        -c|--clean)
            CLEAN=1; shift 2 ;;
        -h|--help)
            print_usage; exit 0 ;;
        --) shift; break ;;
        *)  print_usage; exit 1 ;;
    esac
done

if [[ -z ${DEVICE} ]]; then
    echo "Please assign the device type"
    exit 1
fi

if [[ -f "${ROOT_DIR}/devices/${DEVICE}.sh" ]]; then
#shellcheck disable=SC1090
    source "${ROOT_DIR}/devices/${DEVICE}.sh"
else
    echo "Require customized ${ROOT_DIR}/devices/${DEVICE}.sh or ${ROOT_DIR}/devices/${DEVICE}/${VARIANT}.sh"
    exit 1
fi

curl -sLO "${BASE_URL}/sha256sums"
SHA256_VALUE=$(grep openwrt-sdk sha256sums | cut -d' ' -f1)
SDK_FILENAME=$(grep openwrt-sdk sha256sums | cut -d'*' -f2)
if [[ -f "${CACHE_DIR}/${SDK_FILENAME}" ]]; then
    if [[ $(sha256sum "${CACHE_DIR}/${SDK_FILENAME}" | cut -d' ' -f1) != "${SHA256_VALUE}" ]]; then
        rm -f "${CACHE_DIR}/${SDK_FILENAME}"
    fi
fi

if [[ ! -f "${CACHE_DIR}/${SDK_FILENAME}" ]]; then
    curl -sL "${BASE_URL}/${SDK_FILENAME}" -o "${CACHE_DIR}/${SDK_FILENAME}"
fi
#shellcheck disable=SC2046
if [[ ${CLEAN} -gt 0 && -d $(basename -s .tar.xz "${SDK_FILENAME}") ]]; then rm -fr $(basename -s .tar.xz "${SDK_FILENAME}"); fi
if [[ ! -d $(basename -s .tar.xz "${SDK_FILENAME}") ]]; then tar -xf "${CACHE_DIR}/${SDK_FILENAME}"; fi
