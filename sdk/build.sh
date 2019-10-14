#!/bin/bash

set -a -e -x

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

TARGET=${OPENWRT_TARGET:-""}
VERSION=${OPENWRT_VERSION:-"18.06.4"}
CLEAN=0

print_usage() {
    echo "Usage [-t|--target] <target name> [-V|--version] <openwrt version> [-c|--clean] [-h|--help]"
}

TEMP=$(getopt -o t:v:c::h:: --long target:,version:,clean::,help:: -- "$@")
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -t|--target)
            TARGET=$2; shift 2 ;;
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
if [[ ${CLEAN} -gt 0 && -d "${SDK_DIR}" ]]; then rm -fr "${SDK_DIR}"; fi
if [[ ! -d "${SDK_DIR}" ]]; then tar -xf "${CACHE_DIR}/${SDK_FILENAME}"; fi

if [[ $(command -v pre_ops) ]]; then pre_ops; fi

if [[ -d "${ROOT_DIR}/lede" ]]; then
    (cd "${ROOT_DIR}/lede"; git fetch -p --all; git pull)
else
    git clone https://github.com/coolsnowwolf/lede.git
fi

if [[ -d "${SDK_DIR}/package/lean" ]]; then
    rm -fr "${SDK_DIR}/package/lean"
fi
cp -pr "${ROOT_DIR}/lede/package/lean" "${SDK_DIR}/package"

if [[ -d "${SDK_DIR}/package/v2ray-core" ]]; then
    (cd "${SDK_DIR}/package/v2ray-core"; git fetch -p --all; git pull)
else
    git clone https://github.com/kuoruan/openwrt-v2ray.git "${SDK_DIR}/package/v2ray-core"
fi

if [[ -d "${SDK_DIR}/package/luci-app-v2ray" ]]; then
    (cd "${SDK_DIR}/package/luci-app-v2ray"; git fetch -p --all; git pull)
else
    git clone https://github.com/kuoruan/luci-app-v2ray.git "${SDK_DIR}/package/luci-app-v2ray"
fi

cd "${SDK_DIR}"
./scripts/feeds update -a
./scripts/feeds install -a
# Build ssr-plus
make -j"$(nproc)" package/feeds/luci/luci-base/compile
make -j"$(nproc)" package/lean/luci-app-ssr-plus/compile
make -j"$(nproc)" package/lean/shadowsocksr-libev/compile
make -j"$(nproc)" package/lean/v2ray/compile
make -j"$(nproc)" package/lean/pdnsd-alt/compile
# Build adbyby plus
make -j"$(nproc)" package/lean/adbyby/compile
make -j"$(nproc)" package/lean/luci-app-adbyby-plus/compile
# Build vlmcsd
make -j"$(nproc)" package/lean/luci-app-vlmcsd/compile
make -j"$(nproc)" package/lean/vlmcsd/compile
make package/index

if [[ $(command -v post_ops) ]]; then post_ops; fi
