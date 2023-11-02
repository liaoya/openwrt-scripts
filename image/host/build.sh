#!/bin/bash
#shellcheck disable=SC1090,SC1091,SC2034,SC2164

set -a -e -x

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

BASE_URL=${BASE_URL:-""}
OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-""}
DEVICE=${OPENWRT_DEVICE:-""}
REPOSITORY=${REPOSITORY:-""}
IMAGE_DIR=${IMAGE_DIR:-/work/openwrt/imagebuilder}
VARIANT=${OPENWRT_VARIANT:-"custom"}
VERSION=${OPENWRT_VERSION:-"23.05.0"}
CLEAN=0

function _print_help() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -d, --device, DEVICE NAME
    -p, --repository, the local repository
    -r, --root, the root directory of uncompress folder
    -u, --url, provide the openwrt image builder url directly since the version
    -v, --variant, IMAGE VARIANT
    -V, --version, OpenWRT VERSION
    -c, --clean, clean build
    -h, --help, show help
EOF
}

PACKAGES=${PACKAGES:-""}

function _add_package() {
    while (($#)); do
        if [[ ${PACKAGES} != *"${1}"* ]]; then
            PACKAGES="${PACKAGES:+${PACKAGES} }${1}"
        fi
        shift
    done
}

TEMP=$(getopt -o d:p:r:v:V:ch --long device:repository:,root:,variant:,version:,clean,help -- "$@")
eval set -- "$TEMP"
while true; do
    case "$1" in
    -d | --device)
        shift
        DEVICE=$1
        ;;
    -p | --repository)
        shift
        REPOSITORY=$1
        ;;
    -r | --root)
        shift
        IMAGE_DIR=$(readlink -f "$1")
        ;;
    -u | --url)
        shift
        BASE_URL=$1
        ;;
    -v | --variant)
        shift
        VARIANT=$1
        ;;
    -V | --version)
        #shellcheck disable=SC2034
        shift
        VERSION=$1
        ;;
    -c | --clean)
        CLEAN=1
        ;;
    -h | --help)
        _print_help
        exit 0
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

if [[ -z ${DEVICE} ]]; then
    echo "Please assign the device type"
    exit 1
fi

if [[ $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
    OPENWRT_MIRROR_PATH=http://mirrors.ustc.edu.cn/openwrt
    # OPENWRT_MIRROR_PATH=https://mirror.sjtu.edu.cn/openwrt
    # OPENWRT_MIRROR_PATH=https://mirrors.tuna.tsinghua.edu.cn/openwrt
    # OPENWRT_MIRROR_PATH=https://mirrors.cloud.tencent.com/openwrt
else
    OPENWRT_MIRROR_PATH=http://downloads.openwrt.org
fi

if [[ -f "${ROOT_DIR}/devices/${DEVICE}.sh" ]]; then
    source "${ROOT_DIR}/devices/${DEVICE}.sh"
elif [[ -f "${ROOT_DIR}/devices/${DEVICE}/${VARIANT}.sh" ]]; then
    source "${ROOT_DIR}/devices/${DEVICE}/${VARIANT}.sh"
else
    echo "Require customized ${ROOT_DIR}/devices/${DEVICE}.sh or ${ROOT_DIR}/devices/${DEVICE}/${VARIANT}.sh"
    exit 1
fi

if [[ -z ${BASE_URL} ]]; then
    echo "Please provide \$BASE_URL"
    exit 1
fi

if [[ ! -d "${IMAGE_DIR}" ]]; then mkdir -p "${IMAGE_DIR}"; fi
pushd "${IMAGE_DIR}"

curl -sLO "${BASE_URL}/sha256sums"
# curl -sLO "${BASE_URL}/sha256sums.asc"
# curl -sLO "${BASE_URL}/sha256sums.sig"
# if [ ! -f sha256sums.asc ] && [ ! -f sha256sums.sig ]; then
#     echo "Missing sha256sums signature files"
#     exit 1
# fi
# [ ! -f sha256sums.asc ] || gpg --with-fingerprint --verify sha256sums.asc sha256sums

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

if [[ ! -d ${IMAGE_DIR} ]]; then
    mkdir -p "${IMAGE_DIR}"
fi
IMAGE_BUILDER_DIR=${IMAGE_DIR}/$(basename -s .tar.xz "${IMAGE_BUILDER_FILE}")
if [[ ${CLEAN} -gt 0 && -d ${IMAGE_BUILDER_DIR} ]]; then
    rm -fr "${IMAGE_BUILDER_DIR}"
fi
if [[ ! -d "${IMAGE_BUILDER_DIR}" || -z $(ls -A "${IMAGE_BUILDER_DIR}") ]]; then
    tar -C "${IMAGE_DIR}" -xf "${CACHE_DIR}/${IMAGE_BUILDER_FILE}"
fi

cd "${IMAGE_BUILDER_DIR}"
# if [[ $(command -v pyenv) ]]; then
#     pyenv local 3.8.13
# fi
if [[ -f repositories.conf.bak ]]; then
    cp -r repositories.conf.bak repositories.conf
fi
if [[ ! -f repositories.conf.bak ]]; then
    cp -r repositories.conf repositories.conf.bak
fi
sed -i -e "s|http://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g" -e "s|https://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g" repositories.conf
if [[ -n ${REPOSITORY} && -d ${REPOSITORY} ]]; then
    REPOSITORY=$(readlink -f "${REPOSITORY}")
    if [[ -f ${REPOSITORY}/Packages.gz ]]; then
        echo "src custom_repo file://${REPOSITORY}" >>repositories.conf
        # https://openwrt.org/docs/guide-user/additional-software/imagebuilder
        sed -i 's/^option check_signature$/# &/' repositories.conf
    else
        _PACKAGES=$(for pkg in "${REPOSITORY}"/*.ipk; do basename "$pkg" | cut -d'_' -f1; done | paste -sd " " -)
        PACKAGES="${PACKAGES:+$PACKAGES }${_PACKAGES}"
        unset -n _PACKAGES
        [[ -d packages ]] || mkdir -p packages
        cp "${REPOSITORY}"/*.ipk packages/
    fi
fi

# if [[ -f ~/.ssh/id_rsa.pub ]]; then
#     [[ -d "${ROOT_DIR}/custom/etc/dropbear" ]] || mkdir "${ROOT_DIR}/custom/etc/dropbear"
#     cat ~/.ssh/id_rsa.pub > "${ROOT_DIR}/custom/etc/dropbear/authorized_keys"
# fi
if [[ $(command -v pre_ops) ]]; then pre_ops; fi

[[ ${CLEAN} -gt 0 ]] && make clean
if [[ ${DEVICE} == "x86-64" || ${DEVICE} == "armvirt-64" ]]; then
    make image PACKAGES="${PACKAGES}" FILES="${ROOT_DIR}/custom" EXTRA_IMAGE_NAME="${VARIANT}"
else
    make image PROFILE="${DEVICE}" PACKAGES="${PACKAGES}" FILES="${ROOT_DIR}/custom" EXTRA_IMAGE_NAME="${VARIANT}"
fi

# The following is only for x86 image
if [[ $(command -v qemu-img) && -d bin/targets/x86/64 ]]; then
    while IFS= read -r -d '' _gz_image; do
        _prefix=$(dirname "${_gz_image}")
        _img=${_prefix}/$(basename -s .gz "${_gz_image}")
        _qcow2c=${_prefix}/$(basename -s .img.gz "${_gz_image}").qcow2c
        if [[ ! -f "${_qcow2c}" ]]; then
            if [[ ! -f "${_img}" ]]; then
                gunzip -k "${_gz_image}"
            fi
            qemu-img convert -c -O qcow2 "${_img}" "${_qcow2c}"
            qemu-img convert -O qcow2 "${_qcow2c}" "${_img}" # Ventoy use img
            unset -v _prefix _img _qcow2c
        fi
    done < <(find bin/targets/x86/64 -iname '*-combined-ext4.img.gz' -print0)
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

popd
