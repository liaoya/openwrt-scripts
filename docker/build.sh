#!/bin/bash

set -e

function print_usage() {
    #shellcheck disable=SC2016
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -h, show help.
    -b, the bin directory binding for image output. ${BINDING:+The default is '"${BINDING}"'}
    -c, clean build. ${CLEAN:+The default is "${CLEAN}"}
    -d, the dl directory binding for package cache.
    -k, the directory for customized files. ${KUSTOMIZE:+The default is "${KUSTOMIZE}"}
    -m, use chinese openwrt mirror, overwrited with \$OPENWRT_MIRROR_PATH. ${OPENWRT_MIRROR_PATH:+The current is "${OPENWRT_MIRROR_PATH}"}
    -n, the customize name. ${NAME:+The default is '"${NAME}"'}
    -p, additional packages. ${PACKAGES:+The default is "${PACKAGES}"}
    -v, the openwrt version. ${VERSION:+The default is '"${VERSION}"'}
EOF
}

BINDING=${BINDING:-"$PWD/bin"}
CLEAN=0
DL=${DL:-""}
DOCKER_IMAGE=docker.io/openwrtorg/imagebuilder:x86-64
KUSTOMIZE=${KUSTOMIZE:-""}
NAME=${NAME:-default}
OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://mirrors.ustc.edu.cn/openwrt}
PACKAGES=${PACKAGES:+${PACKAGES} }"kmod-dax kmod-dm" # kmod-dax kmod-dm is required for ventoy
VERSION=${VERSION:-"21.02.2"}

_cmd=""

while getopts "hb:cd:k:mn:p:v:" OPTION; do
    case $OPTION in
    h)
        print_usage
        exit 0
        ;;
    c)
        CLEAN=1
        ;;
    b)
        BINDING=${OPTARG}
        ;;
    d)
        DL=${OPTARG}
        ;;
    k)
        KUSTOMIZE=${OPTARG}
        ;;
    m)
        _cmd=${_cmd:+${_cmd}; }"sed -i -e \"s|http://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g\" -e \"s|https://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g\" repositories.conf"
        ;;
    n)
        NAME=${OPTARG}
        ;;
    p)
        PACKAGES=PACKAGES="${PACKAGES:+$PACKAGES }${OPTARG}"
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
    if [[ -d "${BINDING}" ]]; then
        rm -fr "${BINDING}"
    fi
    if [[ -n ${DL} && -d "${DL}" ]]; then
        rm -fr "${DL}"
    fi
fi
if [[ ! -d ${BINDING} ]]; then
    mkdir -p "${BINDING}"
fi

docker_cmd="docker run --rm -t"
#shellcheck disable=SC2086
docker_cmd=${docker_cmd:+${docker_cmd} }"-u build:$(id -gn) --group-add $(id -gn) -v $(readlink -f ${BINDING}):/home/build/openwrt/bin"
if [[ -n ${DL} ]]; then
    if [[ -d "${DL}" ]]; then
        mkdir -p "${DL}"
    fi
    #shellcheck disable=SC2086
    docker_cmd=${docker_cmd:+${docker_cmd} }"-v $(readlink -f ${DL}):/home/build/openwrt/dl"
fi

for item in http_proxy https_proxy no_proxy; do
    if [[ -n ${!item} ]]; then
        docker_cmd=${docker_cmd:+${docker_cmd} }"--env ${item}=${!item}"
    fi
done

_cmd=${_cmd:+${_cmd}; }"make image EXTRA_IMAGE_NAME=${NAME}"
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
    done < <(find "${BINDING}/targets/x86/64" -iname "*-combined*.img.gz" | grep -v efi | sort)
fi
