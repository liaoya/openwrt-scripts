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
VERSION=${VERSION:-"19.07.2"}
CLEAN=0
MIRROR=0

print_usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -d, --dl, the global dl directory
    -n, --name, the name of uncompress folder, some build will fail if the name is too long.
    -t, --target, CPU Arch
    -u, --url, provide the openwrt image builder url directly for old version (before 17.01)
    -v, --version, OpenWRT VERSION
    -c, --clean, clean build
    -h, --help, show help
    -m, --mirror, choose chinese openwrt mirror
EOF
}

TEMP=$(getopt -o d:n:t:u:v:chm --long dl:,name:,target:,url:,version:,clean,help,mirror -- "$@")
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -d|--dl)
            shift; DL_DIR=$(readlink -f "$1") ;;
        -n|--name)
            shift; NAME=$(readlink -f "$1") ;;
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
# curl -sLO "${BASE_URL}/sha256sums.asc"
# curl -sLO "${BASE_URL}/sha256sums.sig"
# if [ ! -f sha256sums.asc ] && [ ! -f sha256sums.sig ]; then
#     echo "Missing sha256sums signature files"
#     exit 1
# fi
# [ ! -f sha256sums.asc ] || gpg --with-fingerprint --verify sha256sums.asc sha256sums

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
if [[ -d "${SDK_DIR}" ]]; then 
    if [[ ${CLEAN} -gt 0 ]]; then
        rm -fr "${SDK_DIR}"
    else
        eixt 0
    fi
fi
if [[ -n ${NAME} ]]; then
    NAME=$(dirname "${NAME}")
    tar -xf "${CACHE_DIR}/${SDK_FILENAME}" -C "${NAME}"
    NAME=${NAME}/$(basename -s .tar.xz "${SDK_FILENAME}")
    mv "${NAME}" "${SDK_DIR}"
else
    tar -xf "${CACHE_DIR}/${SDK_FILENAME}" -C "${ROOT_DIR}"
fi

[[ -f "${SDK_DIR}"/feeds.conf.default.origin ]] || cp "${SDK_DIR}"/feeds.conf.default "${SDK_DIR}"/feeds.conf.default.origin
[[ -f "${SDK_DIR}"/feeds.conf.default.origin ]] && cp "${SDK_DIR}"/feeds.conf.default.origin "${SDK_DIR}"/feeds.conf.default

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

pushd "${SDK_DIR}"
mkdir -p staging_dir/host/bin
if [[ $(command -v upx) ]]; then cp "$(command -v upx)" staging_dir/host/bin; fi
if [[ $(command -v upx-ucl) ]]; then cp "$(command -v upx-ucl)" staging_dir/host/bin; fi
echo "src-git lienol https://github.com/Lienol/openwrt-package" >> feeds.conf.default
scripts/feeds clean
./scripts/feeds update -a
# Remove the kcptun in package feed
rm -fr feeds/packages/net/kcptun
sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=3.3.4/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/net/shadowsocks-libev/Makefile
./scripts/feeds update -i
./scripts/feeds install -a
make defconfig
make -j"$(nproc)" package/feeds/luci/luci-base/compile
rm -f .config
popd
