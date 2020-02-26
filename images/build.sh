#!/bin/bash
#shellcheck disable=SC1090,SC2034,SC2164

set -a -e -x

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

BASE_URL_PREFIX=${BASE_URL_PREFIX:-http://downloads.openwrt.org}
DEVICE=${OPENWRT_DEVICE:-""}
REPOSITORY=${REPOSITORY:-""}
VARIANT=${OPENWRT_VARIANT:-"custom"}
VERSION=${OPENWRT_VERSION:-"19.07.1"}
CLEAN=0
MIRROR=0

print_usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -d, --device, DEVICE NAME
    -p, --repository, the local repository
    -v, --variant, IMAGE VARIANT
    -V, --version, OpenWRT VERSION
    -c, --clean, clean build
    -h, --help, show help
    -m, --mirror, choose chinese openwrt mirror
EOF
}

TEMP=$(getopt -o d:p:v:V:chm --long device:repository:,variant:,version:,clean,help,mirror -- "$@")
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -d|--device)
            shift; DEVICE=$1 ;;
        -p|--repository)
            shift; REPOSITORY=$1 ;;
        -v|--variant)
            shift; VARIANT=$1 ;;
        -V|--version)
#shellcheck disable=SC2034
            shift; VERSION=$1 ;;
        -c|--clean)
            CLEAN=1 ;;
        -h|--help)
            print_usage; exit 0 ;;
        -m|--mirror)
            MIRROR=1 ;;
        --) shift; break ;;
        *)  print_usage; exit 1 ;;
    esac
    shift
done

if [[ -z ${DEVICE} ]]; then
    echo "Please assign the device type"
    exit 1
fi

if [[ ${MIRROR} -eq 1 ]]; then
#    BASE_URL_PREFIX=http://mirrors.tuna.tsinghua.edu.cn/lede
    BASE_URL_PREFIX=http://mirrors.tuna.tsinghua.edu.cn/lede
fi

if [[ -f "${ROOT_DIR}/devices/${DEVICE}.sh" ]]; then
    source "${ROOT_DIR}/devices/${DEVICE}.sh"
elif [[ -f "${ROOT_DIR}/devices/${DEVICE}/${VARIANT}.sh" ]]; then
    source "${ROOT_DIR}/devices/${DEVICE}/${VARIANT}.sh"
else
    echo "Require customized ${ROOT_DIR}/devices/${DEVICE}.sh or ${ROOT_DIR}/devices/${DEVICE}/${VARIANT}.sh"
    exit 1
fi

curl -sLO "${BASE_URL}/sha256sums"
SHA256_VALUE=$(grep "openwrt-imagebuilder-${VERSION}" sha256sums | cut -d' ' -f1)
IMAGE_BUILDER_FILE=$(grep "openwrt-imagebuilder-${VERSION}" sha256sums | cut -d'*' -f2)
if [[ -f "${CACHE_DIR}/${IMAGE_BUILDER_FILE}" ]]; then
    if [[ $(sha256sum "${CACHE_DIR}/${IMAGE_BUILDER_FILE}" | cut -d' ' -f1) != "${SHA256_VALUE}" ]]; then
        rm -f "${CACHE_DIR}/${IMAGE_BUILDER_FILE}"
    fi
fi

if [[ ! -f "${CACHE_DIR}/${IMAGE_BUILDER_FILE}" ]]; then
    curl -sL "${BASE_URL}/${IMAGE_BUILDER_FILE}" -o "${CACHE_DIR}/${IMAGE_BUILDER_FILE}"
fi
IMAGE_BUILDER_DIR=$(basename -s .tar.xz "${IMAGE_BUILDER_FILE}")
if [[ ${CLEAN} -gt 0 && -d "${IMAGE_BUILDER_DIR}" ]]; then rm -fr "${IMAGE_BUILDER_DIR}"; fi
if [[ ! -d "${IMAGE_BUILDER_DIR}" ]]; then tar -xf "${CACHE_DIR}/${IMAGE_BUILDER_FILE}"; fi

cd "${IMAGE_BUILDER_DIR}"
if [[ -f repositories.conf.bak ]]; then
    cp -r repositories.conf.bak repositories.conf
fi
if [[ ! -f repositories.conf.bak ]]; then
    cp -r repositories.conf repositories.conf.bak
fi
if [[ ${MIRROR} -eq 1 ]]; then
    sed -i -e "s|http://downloads.openwrt.org|${BASE_URL_PREFIX}|g" -e "s|https://downloads.openwrt.org|${BASE_URL_PREFIX}|g" repositories.conf
fi
if [[ -n ${REPOSITORY} && -d ${REPOSITORY} ]]; then
    REPOSITORY=$(readlink -f "${REPOSITORY}")
    _PACKAGES=$(for pkg in "${REPOSITORY}"/*.ipk; do basename "$pkg" | cut -d'_' -f1; done | paste -sd " " -)
    PACKAGES=${PACKAGES:-""}
    PACKAGES="${PACKAGES:+$PACKAGES }${_PACKAGES}"
    unset -n _PACKAGES
    # echo "src custom_repo file://${REPOSITORY}" >> repositories.conf
    [[ -d packages ]] || mkdir -p packages
    cp "${REPOSITORY}"/*.ipk packages/
fi

if [[ -f ~/.ssh/id_rsa.pub ]]; then
    [[ -d "${ROOT_DIR}/custom/etc/dropbear" ]] || mkdir "${ROOT_DIR}/custom/etc/dropbear"
    cat ~/.ssh/id_rsa.pub > "${ROOT_DIR}/custom/etc/dropbear/authorized_keys"
fi
if [[ $(command -v pre_ops) ]]; then pre_ops; fi

[[ ${CLEAN} -gt 0 ]] && make clean
if [[ ${DEVICE} == "x64" || ${DEVICE} == "armvirt" ]]; then
    make -j "$(nproc)" image PACKAGES="${PACKAGES}" FILES="${ROOT_DIR}/custom" EXTRA_IMAGE_NAME="${VARIANT}"
else
    make -j "$(nproc)" image PROFILE="${DEVICE}" PACKAGES="${PACKAGES}" FILES="${ROOT_DIR}/custom" EXTRA_IMAGE_NAME="${VARIANT}"
fi

for item in "${ROOT_DIR}/custom/etc/chinadns_chnroute.txt" \
            "${ROOT_DIR}/custom/etc/config/wireless" \
            "${ROOT_DIR}/custom/etc/dropbear/authorized_keys" \
            "${ROOT_DIR}/custom/etc/opkg"; do
    if [[ -f "${item}" ]]; then
        rm -f "${item}"
    elif [[ -d "${item}" ]]; then
        rm -fr "${item}"
    fi
done

if [[ $(command -v post_ops) ]]; then post_ops; fi
