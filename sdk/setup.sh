#!/bin/bash

set -ex

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

BASE_URL=${BASE_URL:-""}
BASE_URL_PREFIX=${BASE_URL_PREFIX:-""}
DL_DIR=${DL_DIR:-""}
NAME=${NAME:-""}
TARGET=${TARGET:-""}
VERSION=${VERSION:-"19.07.5"}
CLEAN=0
MIRROR=0

function _print_help() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -d, --dl, the global dl directory, the default value "${DL_DIR}"
    -n, --name, the name of uncompress folder, some build will fail if the name is too long.
    -t, --target, CPU Arch
    -v, --version, OpenWRT VERSION
    -c, --clean, clean build
    -h, --help, show help
    -m, --mirror, choose chinese openwrt mirror
EOF
}

while getopts ":d:n:t:v:chm" opt; do
    case $opt in
    d)
        DL_DIR=$OPTARG
        ;;
    n)
        NAME=$OPTARG
        ;;
    t)
        TARGET=$OPTARG
        ;;
    v)
        VERSION=$OPTARG
        ;;
    c)
        CLEAN=1
        ;;
    h)
        _print_help
        exit 0
        ;;
    m)
        MIRROR=1
        ;;
    \?)
        _print_help
        exit 1
        ;;
    esac
done

function check_param() {
    while (($#)); do
        if [[ -z ${!1} ]]; then
            echo "\${$1} is required"
            return 1
        fi
        shift 1
    done
}

if [[ ${MIRROR} -eq 1 ]]; then
    BASE_URL_PREFIX=https://mirrors.tuna.tsinghua.edu.cn/lede
else
    BASE_URL_PREFIX=http://downloads.openwrt.org
fi

check_param ROOT_DIR TARGET

if [[ -f "${ROOT_DIR}/target/${TARGET}.sh" ]]; then
    #shellcheck disable=SC1090
    source "${ROOT_DIR}/target/${TARGET}.sh"
else
    echo "Require customized ${ROOT_DIR}/target/${TARGET}.sh"
    exit 1
fi

check_param BASE_URL

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
    SDK_DIR=${NAME}
else
    SDK_DIR=$(basename -s .tar.xz "${SDK_FILENAME}")
    SDK_DIR=${ROOT_DIR}/${SDK_DIR}
fi
if [[ ${CLEAN} -gt 0 && -d "${SDK_DIR}" ]]; then rm -fr "${SDK_DIR}"; fi
if [[ ! -d "${SDK_DIR}" ]]; then
    if [[ -n ${NAME} ]]; then
        NAME=$(dirname "${NAME}")
        tar -xf "${CACHE_DIR}/${SDK_FILENAME}" -C "${NAME}"
        NAME=${NAME}/$(basename -s .tar.xz "${SDK_FILENAME}")
        mv "${NAME}" "${SDK_DIR}"
    else
        tar -xf "${CACHE_DIR}/${SDK_FILENAME}" -C "${ROOT_DIR}"
    fi
fi

if [[ -n ${DL_DIR} ]]; then
    if [[ -d "${SDK_DIR}/dl" ]]; then rm -fr "${SDK_DIR}/dl"; fi
    if [[ ! -L "${SDK_DIR}/dl" ]]; then ln -s "${DL_DIR}" "${SDK_DIR}/dl"; fi
fi

[[ -f "${SDK_DIR}"/feeds.conf.default.origin ]] || cp "${SDK_DIR}"/feeds.conf.default "${SDK_DIR}"/feeds.conf.default.origin
[[ -f "${SDK_DIR}"/feeds.conf.default.origin ]] && cp "${SDK_DIR}"/feeds.conf.default.origin "${SDK_DIR}"/feeds.conf.default

# https://github.com/Lienol/openwrt-packages;packages-19.07
# sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
#     -e 's|git.openwrt.org/feed/packages|github.com/openwrt/packages|g' \
#     -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
#     -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
#     -i "${SDK_DIR}"/feeds.conf.default
sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e '/^src-git packages http/d' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -i "${SDK_DIR}"/feeds.conf.default
echo "src-git packages https://github.com/Lienol/openwrt-packages;19.07" >>"${SDK_DIR}"/feeds.conf.default
echo "src-git Lienol https://github.com/Lienol/openwrt-package" >>"${SDK_DIR}"/feeds.conf.default
if [[ ${VERSION} =~ 19.07 ]]; then
    echo "src-git liuran001 https://github.com/liuran001/openwrt-packages;packages-19.07" >>"${SDK_DIR}"/feeds.conf.default
else
    echo "src-git liuran001 https://github.com/liuran001/openwrt-packages;packages" >>"${SDK_DIR}"/feeds.conf.default
fi
echo "src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall" >>"${SDK_DIR}"/feeds.conf.default

pushd "${SDK_DIR}"

mkdir -p staging_dir/host/bin
if [[ $(command -v upx) && ! -L staging_dir/host/bin/upx ]]; then ln -s "$(command -v upx)" staging_dir/host/bin; fi
if [[ $(command -v upx-ucl) && ! -L staging_dir/host/bin/upx-ucl ]]; then ln -s "$(command -v upx-ucl)" staging_dir/host/bin; fi

scripts/feeds clean
./scripts/feeds update -a

# Remove the kcptun in package feed since it's quite old
rm -fr feeds/packages/net/kcptun
# Fail to update node, need investigation
# sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=v12.15.0/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/lang/node/Makefile
# sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=3.3.4/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/net/shadowsocks-libev/Makefile
# Refer to https://github.com/openwrt/packages/blob/master/net/shadowsocks-libev/Makefile
sed -i -e 's/^PKG_VERSION:=.*/PKG_VERSION:=3.3.5/g' \
    -e 's/^PKG_RELEASE:=.*/PKG_RELEASE:=1/g' \
    -e 's/^PKG_HASH:=.*/PKG_HASH:=cfc8eded35360f4b67e18dc447b0c00cddb29cc57a3cec48b135e5fb87433488/g' feeds/packages/net/shadowsocks-libev/Makefile

./scripts/feeds update -i
./scripts/feeds install -a

rm -fr .config ./tmp
make defconfig

if [[ $(command -v pre_ops) ]]; then pre_ops; fi

make -j"$(nproc)" package/feeds/luci/luci-base/compile

# for src_dir in package/feeds/Lienol package/feeds/liuran001 package/feeds/xiaorouji; do
#     for pkg in "${src_dir}"/*; do
#         [[ -d ${pkg} ]] || continue
#         make -j"$(nproc)" "${pkg}"/compile || true
#     done
# done