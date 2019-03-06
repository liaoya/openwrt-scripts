#!/bin/bash
#shellcheck disable=SC1090,SC2164

set -a -e -x

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

DEVICE=""
VARIANT=""
VERSION="18.06.2"
CLEAN=0

print_usage() {
    echo "Usage [-d|--device] <device name> [-v|--variant] [image variant] [-V|--version] <openwrt version> [-c|--clean] [-h|--help]"
}

TEMP=$(getopt -o d:v:c::h:: --long device:,version:,clean::,help:: -- "$@")
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -d|--device)
            DEVICE=$2; shift 2 ;;
        -v|--variant)
            VARIANT=$2; shift 2 ;;
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

if [[ -f "${THIS_DIR}/devices/${DEVICE}.sh" ]]; then
    source "${THIS_DIR}/devices/${DEVICE}.sh"
elif [[ -f "${THIS_DIR}/devices/${DEVICE}/${VARIANT}.sh" ]]; then
    source "${THIS_DIR}/devices/${DEVICE}/${VARIANT}.sh"
else
    echo "Require customized ${THIS_DIR}/devices/${DEVICE}.sh or ${THIS_DIR}/devices/${DEVICE}/${VARIANT}.sh"
    exit 1
fi

curl -sLO "${BASE_URL}/sha256sums"
SHA256_VALUE=$(grep imagebuilder sha256sums | cut -d' ' -f1)
IMAGE_BUILDER_FILENAME=$(grep imagebuilder sha256sums | cut -d'*' -f2)
if [[ -f "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}" ]]; then
    if [[ $(sha256sum "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}" | cut -d' ' -f1) != "${SHA256_VALUE}" ]]; then
        rm -f "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}"
    fi
fi

if [[ ! -f "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}" ]]; then
    curl -sL "${BASE_URL}/${IMAGE_BUILDER_FILENAME}" -o "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}"
fi
#shellcheck disable=SC2046
if [[ ${CLEAN} -gt 0 && -d $(basename -s .tar.xz "${IMAGE_BUILDER_FILENAME}") ]]; then rm -fr $(basename -s .tar.xz "${IMAGE_BUILDER_FILENAME}"); fi
if [[ ! -d $(basename -s .tar.xz "${IMAGE_BUILDER_FILENAME}") ]]; then tar -xf "${CACHE_DIR}/${IMAGE_BUILDER_FILENAME}"; fi

#shellcheck disable=SC2046
cd $(basename -s .tar.xz "${IMAGE_BUILDER_FILENAME}")
if [[ -f repositories.conf.bak ]]; then
    cp -r repositories.conf.bak repositories.conf
fi
if [[ ! -f repositories.conf.bak ]]; then
    cp -r repositories.conf repositories.conf.bak
fi
if [[ -f ~/.ssh/id_rsa.pub ]]; then
    [[ -d "${THIS_DIR}/custom/etc/dropbear" ]] || mkdir "${THIS_DIR}/custom/etc/dropbear"
    cat ~/.ssh/id_rsa.pub > "${THIS_DIR}/custom/etc/dropbear/authorized_keys"
fi
if [[ $(command -v pre_ops) ]]; then pre_ops; fi

[[ ${CLEAN} -gt 0 ]] && make clean
if [[ -n ${VARIANT} ]]; then
    make -j "$(nproc)" image PROFILE="${DEVICE}" PACKAGES="${PACKAGES}" FILES="${THIS_DIR}/custom" EXTRA_IMAGE_NAME="${VARIANT}"
else
    make -j "$(nproc)" image PROFILE="${DEVICE}" PACKAGES="${PACKAGES}" FILES="${THIS_DIR}/custom" EXTRA_IMAGE_NAME=custom
fi

for item in "${THIS_DIR}/custom/etc/chinadns_chnroute.txt" \
            "${THIS_DIR}/custom/etc/config/wireless" \
            "${THIS_DIR}/custom/etc/dropbear/authorized_keys" \
            "${THIS_DIR}/custom/etc/opkg"; do
    if [[ -f "${item}" ]]; then
        rm -f "${item}"
    elif [[ -d "${item}" ]]; then
        rm -fr "${item}"
    fi
done

if [[ $(command -v post_ops) ]]; then post_ops; fi
