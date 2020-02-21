#!/bin/bash
#shellcheck disable=SC2034

set -a -e -x

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

BASE_URL_PREFIX=http://downloads.openwrt.org
TARGET=${OPENWRT_TARGET:-""}
VERSION=${OPENWRT_VERSION:-"18.06.6"}
CLEAN=0
MIRROR=0

print_usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -t, --target, CPU Arch
    -v, --version, OpenWRT VERSION
    -c, --clean, clean build
    -h, --help, show help
    -m, --mirror, choose chinese openwrt mirror
EOF
}

TEMP=$(getopt -o t:v:chm --long target:,version:,clean,help,mirror -- "$@")
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -t|--target)
            shift; TARGET=$1; ;;
        -v|--version)
#shellcheck disable=SC2034
            shift; VERSION=$1; ;;
        -c|--clean)
            CLEAN=1; ;;
        -h|--help)
            print_usage; exit 0; ;;
        -m|--mirror)
            MIRROR=1; ;;
        --) shift; break ;;
        *)  print_usage; exit 1; ;;
    esac
    shift
done

if [[ ${MIRROR} -eq 1 ]]; then
#    BASE_URL_PREFIX=http://mirrors.tuna.tsinghua.edu.cn/lede
    BASE_URL_PREFIX=http://mirrors.tuna.tsinghua.edu.cn/lede
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
SDK_DIR=$(basename -s .tar.xz "${SDK_FILENAME}")
SDK_DIR="${ROOT_DIR}/${SDK_DIR}"
if [[ ${CLEAN} -gt 0 && -d "${SDK_DIR}" ]]; then rm -fr "${SDK_DIR}"; fi
if [[ ! -d "${SDK_DIR}" ]]; then tar -xf "${CACHE_DIR}/${SDK_FILENAME}"; fi

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
