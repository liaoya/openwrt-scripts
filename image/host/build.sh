#!/bin/bash
#shellcheck disable=SC1090,SC1091,SC2034,SC2164

set -ae

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
#shellcheck disable=SC1091
source "${THIS_DIR}/../common.sh"

CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

DISTRIBUTION=${DISTRIBUTION:-OpenWRT}
DRYRUN=${DRYRUN:-0}
NOCUSTOMIZE=${NOCUSTOMIZE:-0}
ROOTFS_PARTSIZE=${ROOTFS_PARTSIZE:-0}
VERSION=${VERSION:-23.05.2}

function _print_help() {
    #shellcheck disable=SC2016
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -h, --help
        Display help text and exit. No other output is generated.
    -c, --clean
        Clean the previous build
    -b, --bindir BINDIR
        BIN_DIR="<path>" # alternative output directory for the images. ${BINDIR:+The default is '"${BINDIR}"'}
    --build-dir BUILD_DIR
        the build_dir directory binding for temporary output, cache it for speed build. ${BUILD_DIR:+The default is '"${BUILD_DIR}"'}
    -d, --disableservice DISABLESERVICE
        DISABLED_SERVICES="<svc1> [<svc2> [<svc3> ..]]" # Which services in /etc/init.d/ should be disabled. ${DISABLESERVICE:+The default is '"${DISABLESERVICE}"'}
    --distribution DISTRIBUTION
        OpenWRT or ImmortalWrt. ${DISTRIBUTION:+The default is '"${DISTRIBUTION}"'}
    -f, --files FILES
        FILES="<path>" # include extra FILES from <path>. ${FILES:+The default is '"${FILES}"'}
    -n, --name NAME
        EXTRA_IMAGE_NAME="<string>" # Add this to the output image filename (sanitized). ${NAME:+The default is '"${NAME}"'}
    --nocustomize
        Exclude the common configuration for /etc/uci-defaults. ${NO_CUSTOMIZE:+The default is '"${NO_CUSTOMIZE}"'}
    -p, --profile PROFILE
        PROFILE="<profilename>" # override the default target PROFILE. ${PROFILE:+The default is '"${PROFILE}"'}
    -s, --partsize ROOTFS_PARTSIZE
        ROOTFS_PARTSIZE="<size>" # override the default rootfs partition size in MegaBytes. ${ROOTFS_PARTSIZE:+The default is '"${ROOTFS_PARTSIZE}"'}
    -t, --target TARGET
        OpenWRT TARGET(used for image tag), e.g. armsr-armv8(armvirt-64), ath79-nand, ramips-mt7621, x86-64. ${TARGET:+The default is '"${TARGET}"'}
    -T, --thirdparty THIRDPARTY
        Thirdparty package directory. ${THIRDPARTY:+The default is '"${THIRDPARTY}"'}
    -v, --VERSION VERSION
       OpenWRT or ImmortalWrt version(used for image tag). ${VERSION:+The default is '"${VERSION}"'}
    --verbose
        More information
    --dryrun
        Only kick start the shell, skip the final build step. ${DRYRUN:+The default is '"${DRYRUN}"'}
EOF
}

TEMP=$(getopt -o b:d:f:n:p:s:t:T:v:hc --long bindir:,build-dir:,disableservice:,distribution:,files:,name:,,partsize,profile:,target:,thirdparty:,version:,verbose,help,clean,dryrun,nocustomize -- "$@")
eval set -- "${TEMP}"
while true; do
    shift_step=2
    case "$1" in
    -b | --bindir)
        BINDIR=$(readlink -f "$2")
        ;;
    --build-dir)
        BUILD_DIR=$(readlink -f "$2")
        ;;
    -d | --disableservice)
        DISABLESERVICE=$2
        ;;
    --distribution)
        DISTRIBUTION=$2
        ;;
    -f | --files)
        FILES=$(readlink -f "$2")
        ;;
    -n | --name)
        NAME=$2
        ;;
    -p | --profile)
        PROFILE=$2
        ;;
    -s | --partsize)
        ROOTFS_PARTSIZE=$2
        ;;
    -t | --target)
        TARGET=$2
        ;;
    -T | --thirdparty)
        THIRDPARTY=$2
        ;;
    -v | --VERSION)
        VERSION=$2
        ;;
    --verbose)
        shift_step=1
        set -x
        export PS4='+(${BASH_SOURCE[0]}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
        ;;
    -h | --help)
        _print_help
        exit 0
        ;;
    -c | --clean)
        shift_step=1
        CLEAN=1
        ;;
    --dryrun)
        shift_step=1
        DRYRUN=1
        ;;
    --nocustomize)
        shift_step=1
        NOCUSTOMIZE=1
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
    shift "${shift_step}"
done

if [[ -n ${FILES} && ${NOCUSTOMIZE} -gt 0 ]]; then
    echo "${FILES} will not be used as \${NOCUSTOMIZE} is ${NOCUSTOMIZE}"
fi

DISTRIBUTION=${DISTRIBUTION,,}
if [[ ${DISTRIBUTION} != openwrt && ${DISTRIBUTION} != immortalwrt ]]; then
    echo "Only OpenWRT or ImmortalWrt is supported"
fi
if [[ -z ${BINDIR} ]]; then
    BINDIR=${THIS_DIR}/${DISTRIBUTION}-${TARGET}${PROFILE:+"-${PROFILE}"}-${VERSION}-bin
fi
if [[ ${CLEAN:-0} -gt 0 ]] && [[ -d "${BINDIR}" ]]; then
    rm -fr "${BINDIR}"
fi
if [[ ! -d ${BINDIR} ]]; then mkdir -p "${BINDIR}"; fi
if [[ -n ${BUILD_DIR} ]]; then
    if [[ ! -d ${BUILD_DIR} ]]; then
        mkdir -p "${BUILD_DIR}"
    fi
fi

_check_param TARGET VERSION
MAJOR_VERSION=$(echo "${VERSION}" | cut -d. -f1,2)
MAJOR_VERSION_NUMBER=$(echo "${MAJOR_VERSION} * 100 / 1" | bc)

if [[ -z ${PROFILE} && ${TARGET} == "x86-64" ]]; then
    if [[ MAJOR_VERSION_NUMBER -le 1907 ]]; then
        PROFILE=Generic
    else
        PROFILE=generic
    fi
fi
if [[ ! ${TARGET} =~ armvirt && ! ${TARGET} =~ armsr ]]; then
    _check_param PROFILE
fi

if [[ ${DISTRIBUTION} == openwrt ]]; then
    if [[ $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
        OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://mirrors.ustc.edu.cn/openwrt}
    else
        OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-https://downloads.openwrt.org}
    fi
elif [[ ${DISTRIBUTION} == immortalwrt ]]; then
    if [[ $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
        OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://mirror.sjtu.edu.cn/immortalwrt}
    else
        OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://immortalwrt.kyarucloud.moe/}
    fi
fi

_TEMP_DIR=$(mktemp -d)
_add_exit_hook "sudo rm -fr ${_TEMP_DIR}"
BASE_URL=${OPENWRT_MIRROR_PATH}/releases/${VERSION}/targets/${TARGET/-/\/}

curl -sL -o "${_TEMP_DIR}/sha256sums"  "${BASE_URL}/sha256sums"

SHA256_VALUE=$(grep "openwrt-imagebuilder-${VERSION}" "${_TEMP_DIR}/sha256sums" | cut -d' ' -f1)
IMAGE_BUILDER_FILE=$(grep "openwrt-imagebuilder-${VERSION}" "${_TEMP_DIR}/sha256sums" | cut -d'*' -f2)
if [[ -f "${CACHE_DIR}/${IMAGE_BUILDER_FILE}" ]]; then
    if [[ $(sha256sum "${CACHE_DIR}/${IMAGE_BUILDER_FILE}" | cut -d' ' -f1) != "${SHA256_VALUE}" ]]; then
        rm -f "${CACHE_DIR}/${IMAGE_BUILDER_FILE}"
    fi
fi

if [[ ! -f "${CACHE_DIR}/${IMAGE_BUILDER_FILE}" ]]; then
    curl -sL "${BASE_URL}/${IMAGE_BUILDER_FILE}" -o "${CACHE_DIR}/${IMAGE_BUILDER_FILE}"
fi

IMAGE_BUILDER_DIR=${_TEMP_DIR}/$(basename -s .tar.xz "${IMAGE_BUILDER_FILE}")
if [[ ${CLEAN} -gt 0 && -d ${IMAGE_BUILDER_DIR} ]]; then
    rm -fr "${IMAGE_BUILDER_DIR}"
fi
if [[ ! -d "${IMAGE_BUILDER_DIR}" || -z $(ls -A "${IMAGE_BUILDER_DIR}") ]]; then
    tar -C "${_TEMP_DIR}" -xf "${CACHE_DIR}/${IMAGE_BUILDER_FILE}"
fi

exit 0

cd "${IMAGE_BUILDER_DIR}"
if [[ $(command -v pyenv) ]] && ! pyenv versions | grep -F '* 3.10'; then
    #shellcheck disable=SC2046
    pyenv local $(pyenv versions | grep "3.10.")
fi
if [[ -f repositories.conf.bak ]]; then
    cp -r repositories.conf.bak repositories.conf
fi
if [[ ! -f repositories.conf.bak ]]; then
    cp -r repositories.conf repositories.conf.bak
fi
sed -i repositories.conf \
    -e "s|http://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g" \
    -e "s|https://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g" \
    -e "s|http://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g" \
    -e "s|https://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g" \
    -e "s|http://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g" \
    -e "s|https://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g"
if [[ -n ${THIRDPARTY} ]]; then
    if [[ ${THIRDPARTY:0:4} == http ]]; then
        sed -i repositories.conf \
            -e "\|^## This is the local package repository.*|a src custom ${THIRDPARTY}" \
            -e 's/^option check_signature$/# &/'
    else
        sed -i repositories.conf \
            -e "\|^## Place your custom repositories here.*|a src custom file://${MOUNT_DIR}/thirdparty" \
            -e 's/^option check_signature$/# &/'
    fi
fi

if [[ ${TARGET} == "x86-64" ]]; then
    _add_package kmod-dax kmod-dm
fi

[[ ${CLEAN} -gt 0 ]] && make clean
if [[ ${DEVICE} == "x86-64" || ${DEVICE} == "armvirt-64" ]]; then
    make image PACKAGES="${PACKAGES}" FILES="${ROOT_DIR}/custom" EXTRA_IMAGE_NAME="${VARIANT}"
else
    make image PROFILE="${DEVICE}" PACKAGES="${PACKAGES}" FILES="${ROOT_DIR}/custom" EXTRA_IMAGE_NAME="${VARIANT}"
fi

# The following is only for x86 image
if [[ $(command -v qemu-img) && ${TARGET} == "x86-64" && ${DRYRUN:-0} -eq 0 ]]; then
    while IFS= read -r _gz_image; do
        _prefix=$(dirname "${_gz_image}")
        _img=${_prefix}/$(basename -s .gz "${_gz_image}")
        _qcow=${_prefix}/$(basename -s .img.gz "${_gz_image}").qcow2c
        if [[ -f "${_qcow}" && ${_gz_image} != *"squashfs"* ]] || [[ -f "${_img}" && ${_gz_image} == *"squashfs"* ]]; then
            continue
        fi
        if [[ ! -f "${_img}" ]]; then
            gunzip -k "${_gz_image}" || true
        fi
        # Ventoy use img
        if [[ ${_gz_image} == *"squashfs"* ]]; then
            qemu-img convert -O qcow2 "${_img}" "${_qcow}"
            mv "${_qcow}" "${_img}"
        else
            qemu-img convert -c -O qcow2 "${_img}" "${_qcow}"
            qemu-img convert -O qcow2 "${_qcow}" "${_img}"
        fi
        unset -v _prefix _img _qcow
    done < <(find "${BINDIR}/targets/x86/64" -iname "*-combined*.img.gz" | grep -v efi | sort)
fi
