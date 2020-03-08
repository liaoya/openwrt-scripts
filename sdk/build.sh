#!/bin/bash
#shellcheck disable=SC2034

set -a -e -x

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

BASE_URL=${BASE_URL:-""}
BASE_URL_PREFIX=${BASE_URL_PREFIX:-""}
DL_DIR=${DL_DIR:-""}
NAME=${NAME:-""}
TARGET=${TARGET:-""}
VERSION=${VERSION:-"19.07.1"}
CLEAN=0
MIRROR=0

print_usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -d, --dl, the global dl directory
    -n, --name, the name of uncompress folder, some build will fail if the name is too long.
    -t, --target, CPU Arch
    -u, --url, provide the openwrt image builder url directly since the version
    -v, --version, OpenWRT VERSION
    -c, --clean, clean build
    -h, --help, show help
    -m, --mirror, choose chinese openwrt mirror
EOF
}

TEMP=$(getopt -o d:t:v:chm --long dl:,target:,version:,clean,help,mirror -- "$@")
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -d|--dl)
            shift; DL_DIR=$1 ;;
        -n|--name)
            shift; NAME=$1 ;;
        -t|--target)
            shift; TARGET=$1 ;;
        -u|--url)
            shift; BASE_URL=$1 ;;
        -v|--version)
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

if [[ ${VERSION} =~ 19.07 || ${VERSION} =~ 18.06 || ${VERSION} =~ 17.01 ]]; then
    if [[ ${MIRROR} -eq 1 ]]; then
        BASE_URL_PREFIX=http://mirrors.tuna.tsinghua.edu.cn/lede
    else
        BASE_URL_PREFIX=http://downloads.openwrt.org
    fi
else
    if [[ -z ${BASE_URL} ]]; then
        echo "Please provide \$BASE_URL"
        exit 1
    fi
fi

if [[ -z ${TARGET} ]]; then
    echo "Please assign the device type"
    exit 1
fi

if [[ -f "${ROOT_DIR}/target/${TARGET}.sh" ]]; then
#shellcheck disable=SC1090
    source "${ROOT_DIR}/target/${TARGET}.sh"
else
    echo "Require customized ${ROOT_DIR}/target/${TARGET}.sh"
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
if [[ -n ${NAME} ]]; then
    if [[ ${CLEAN} -gt 0 && -d "${NAME}" ]]; then rm -fr "${NAME}"; fi
    SDK_DIR=$(dirname "${NAME}")
    tar -xf "${CACHE_DIR}/${SDK_FILENAME}" -C "${SDK_DIR}"
    SDK_DIR=${SDK_DIR=}/$(basename -s .tar.xz "${SDK_FILENAME}")
else
    SDK_DIR=$(basename -s .tar.xz "${SDK_FILENAME}")
    SDK_DIR=${ROOT_DIR}/${SDK_DIR}
    if [[ ${CLEAN} -gt 0 && -d "${SDK_DIR}" ]]; then rm -fr "${SDK_DIR}"; fi
    if [[ ! -d "${SDK_DIR}" ]]; then tar -xf "${CACHE_DIR}/${SDK_FILENAME}"; fi
fi

sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e 's|git.openwrt.org/feed/packages|github.com/openwrt/packages|g' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -i "${SDK_DIR}"/feeds.conf.default

if [[ -n ${DL_DIR} ]]; then
    if [[ -d "${SDK_DIR}/dl" ]]; then rm -fr "${SDK_DIR}/dl"; fi
    ln -s "${DL_DIR}" "${SDK_DIR}/dl"
fi

if [[ $(command -v pre_ops) ]]; then pre_ops; fi

# if [[ -d "${ROOT_DIR}/lede" ]]; then
#     (cd "${ROOT_DIR}/lede"; git fetch -p --all; git pull)
# else
#     git clone https://github.com/coolsnowwolf/lede.git
# fi

# if [[ -d "${SDK_DIR}/package/lean" ]]; then
#     rm -fr "${SDK_DIR}/package/lean"
# fi
# cp -pr "${ROOT_DIR}/lede/package/lean" "${SDK_DIR}/package"

# if [[ -d "${SDK_DIR}/package/v2ray-core" ]]; then
#     (cd "${SDK_DIR}/package/v2ray-core"; git fetch -p --all; git pull)
# else
#     git clone https://github.com/kuoruan/openwrt-v2ray.git "${SDK_DIR}/package/v2ray-core"
# fi

# if [[ -d "${SDK_DIR}/package/luci-app-v2ray" ]]; then
#     (cd "${SDK_DIR}/package/luci-app-v2ray"; git fetch -p --all; git pull)
# else
#     git clone https://github.com/kuoruan/luci-app-v2ray.git "${SDK_DIR}/package/luci-app-v2ray"
# fi

# cd "${SDK_DIR}"
# echo "src-git lienol https://github.com/Lienol/openwrt-package;master" >> feeds.conf.default
# ./scripts/feeds update -a
# ./scripts/feeds install -a
# ./scripts/feeds update -a
# ./scripts/feeds install -a
# make -j"$(nproc)" package/feeds/luci/luci-base/compile
# make -j"$(nproc)" package/feeds/lienol/luci-app-passwall/compile

# for item in "${SDK_DIR}"/package/lean/*; do
#     if [[ -d "${item}" ]]; then
#         name=$(basename "${item}")
#         make -j"$(nproc)" "package/lean/${name}/compile" || true
#     fi
# done

# make package/index

# if [[ $(command -v post_ops) ]]; then post_ops; fi
