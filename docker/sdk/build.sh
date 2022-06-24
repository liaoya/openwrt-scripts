#!/bin/bash

set -e

function print_usage() {
    #shellcheck disable=SC2016
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
    -h, show help.
    -b, the bin directory binding for image output. ${BIN_DIR:+The default is '"${BIN_DIR}"'}
    -c, clean build. ${CLEAN:+The default is "${CLEAN}"}
    -d, the dl directory binding for package cache. ${DL_DIR:+The default is '"${DL_DIR}"'}
    -k, the directory for customized files. ${KUSTOMIZE:+The default is "${KUSTOMIZE}"}
    -n, the customize name. ${NAME:+The default is '"${NAME}"'}
    -p, the profile. ${NAME:+The default is '"${NAME}"'}
    -v, the openwrt version. ${VERSION:+The default is '"${VERSION}"'}
EOF
}

BIN_DIR=${BIN_DIR:-"$PWD/bin"}
CLEAN=0
DL_DIR=${DL_DIR:-""}
DOCKER_IMAGE=docker.io/openwrtorg/imagebuilder:x86-64
KUSTOMIZE=${KUSTOMIZE:-""}
NAME=${NAME:-default}
PACKAGES=${PACKAGES:+${PACKAGES} }"kmod-dax kmod-dm" # kmod-dax kmod-dm is required for ventoy
PROFILE=${PROFILE:-""}
VERSION=${VERSION:-"21.02.3"}

_cmd=""
if [[ $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
    OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://mirrors.ustc.edu.cn/openwrt}
    _cmd=${_cmd:+${_cmd}; }"sed -i -e \"s|http://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g\" -e \"s|https://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g\" repositories.conf"
fi

while getopts "ha:b:cd:k:n:p:v:" OPTION; do
    case $OPTION in
    h)
        print_usage
        exit 0
        ;;
    c)
        CLEAN=1
        ;;
    a)
        PACKAGES=PACKAGES="${PACKAGES:+$PACKAGES }${OPTARG}"
        ;;
    b)
        BIN_DIR=${OPTARG}
        ;;
    d)
        DL_DIR=${OPTARG}
        ;;
    k)
        KUSTOMIZE=${OPTARG}
        ;;
    n)
        NAME=${OPTARG}
        ;;
    p)
        PROFILE=${OPTARG}
        ;;
    v)
        VERSION=${OPTARG}
        ;;
    *)
        print_usage
        exit 1
        ;;
    esac
done

if [[ ${CLEAN} -gt 0 ]]; then
    if [[ -d "${BIN_DIR}" ]]; then
        rm -fr "${BIN_DIR}"
    fi
    if [[ -n ${DL_DIR} && -d "${DL_DIR}" ]]; then
        rm -fr "${DL_DIR}"
    fi
fi
if [[ ! -d ${BIN_DIR} ]]; then
    mkdir -p "${BIN_DIR}"
fi

docker_cmd="docker run --rm -t"
#shellcheck disable=SC2086
docker_cmd=${docker_cmd:+${docker_cmd} }"-u build:$(id -gn) --group-add $(id -gn) -v $(readlink -f ${BIN_DIR}):/home/build/openwrt/bin"
if [[ -n ${DL_DIR} ]]; then
    if [[ -d "${DL_DIR}" ]]; then
        mkdir -p "${DL_DIR}"
    fi
    #shellcheck disable=SC2086
    docker_cmd=${docker_cmd:+${docker_cmd} }"-v $(readlink -f ${DL_DIR}):/home/build/openwrt/dl"
fi

for item in http_proxy https_proxy no_proxy; do
    if [[ -n ${!item} ]]; then
        docker_cmd=${docker_cmd:+${docker_cmd} }"--env ${item}=${!item}"
    fi
done

_cmd=${_cmd:+${_cmd}; }"make image ${PROFILE:+PROFILE=${PROFILE}} EXTRA_IMAGE_NAME=${NAME}"
if [[ -n ${KUSTOMIZE} ]]; then
    _cmd="${_cmd} FILES=customize"
    #shellcheck disable=SC2086
    docker_cmd=${docker_cmd:+${docker_cmd} }"-v $(readlink -f ${KUSTOMIZE}):/home/build/openwrt/customize"
fi
if [[ -n ${PACKAGES} ]]; then
    _cmd="${_cmd} PACKAGES=\"${PACKAGES}\""
fi
if [[ -n ${CONFIG_TARGET_KERNEL_PARTSIZE} ]]; then
    _cmd="${_cmd} CONFIG_TARGET_KERNEL_PARTSIZE=${CONFIG_TARGET_KERNEL_PARTSIZE}"
fi
if [[ -n ${CONFIG_TARGET_ROOTFS_PARTSIZE} ]]; then
    _cmd="${_cmd} CONFIG_TARGET_ROOTFS_PARTSIZE=${CONFIG_TARGET_ROOTFS_PARTSIZE}"
fi

eval "${docker_cmd} ${DOCKER_IMAGE}-${VERSION} bash -c '${_cmd}'"

# qemu-img convert to make the image as thin provision, do not compress it any more to make backing file across pool
if [[ $(command -v qemu-img) ]]; then
    while IFS= read -r _gz_image; do
        _prefix=$(dirname "${_gz_image}")
        _img=${_prefix}/$(basename -s .gz "${_gz_image}")
        _qcow=${_prefix}/$(basename -s .img.gz "${_gz_image}").qcow2c
        if [[ -f "${_qcow}" ]]; then
            continue
        fi
        if [[ ! -f "${_img}" ]]; then
            gunzip -k "${_gz_image}" || true
        fi
        qemu-img convert -c -O qcow2 "${_img}" "${_qcow}"
        qemu-img convert -O qcow2 "${_qcow}" "${_img}" # Ventoy use img
        unset -v _prefix _img _qcow
    done < <(find "${BIN_DIR}/targets/x86/64" -iname "*-combined*.img.gz" | grep -v efi | sort)
fi
