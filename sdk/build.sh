#!/bin/bash
#shellcheck disable=SC2034

set -aex

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

BASE_URL=${BASE_URL:-""}
BASE_URL_PREFIX=${BASE_URL_PREFIX:-""}
BUILD=0
DL_DIR=${DL_DIR:-""}
LEAN_DIR=${LEAN_DIR:-/work/github/coolsnowwolf/lede}
LIENOL_DIR=${LIENOL_DIR:-/work/github/Lienol/openwrt}
SMARTDNS_DIR=${SMARTDNS_DIR:-/work/github/pymumu/smartdns}
NAME=${NAME:-""}
TARGET=${TARGET:-""}
VERSION=${VERSION:-"19.07.8"}
CLEAN=0
MIRROR=0

function _print_help() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -b, --build, perform build
    -d, --dl, the global dl directory, the default value "${DL_DIR}"
    -n, --name, the name of uncompress folder, some build will fail if the name is too long.
    -t, --target, CPU Arch
    -u, --url, provide the openwrt image builder url directly for old version (before 17.01)
    -v, --version, OpenWRT VERSION
    -c, --clean, clean build
    -h, --help, show help
    -m, --mirror, choose chinese openwrt mirror
EOF
}

TEMP=$(getopt -o b:d:n:t:u:v:chm --long build,dl:,name:,target:,url:,version:,clean,help,mirror -- "$@")
eval set -- "$TEMP"
while true; do
    case "$1" in
    -b | --build)
        BUILD=1
        ;;
    -d | --dl)
        shift
        DL_DIR=$(readlink -f "$1")
        ;;
    -n | --name)
        shift
        NAME=$(readlink -f "$1")
        ;;
    -t | --target)
        shift
        TARGET=$1
        ;;
    -u | --url)
        shift
        BASE_URL=$1
        ;;
    -v | --version)
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
    -m | --mirror)
        MIRROR=1
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

if [[ ${VERSION} =~ 19.07 || ${VERSION} =~ 18.06 || ${VERSION} =~ 17.01 ]]; then
    if [[ ${MIRROR} -eq 1 ]]; then
        BASE_URL_PREFIX=http://mirrors.ustc.edu.cn/openwrt
        # BASE_URL_PREFIX=https://mirror.sjtu.edu.cn/openwrt
        # BASE_URL_PREFIX=https://mirrors.tuna.tsinghua.edu.cn/openwrt
        # BASE_URL_PREFIX=https://mirrors.cloud.tencent.com/openwrt/
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
    SDK_DIR=${NAME}
else
    SDK_DIR=$(basename -s .tar.xz "${SDK_FILENAME}")
    SDK_DIR=${ROOT_DIR}/${SDK_DIR}
fi
#shellcheck disable=SC2046
mkdir -p $(dirname "${SDK_DIR}")
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

sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e 's|git.openwrt.org/feed/packages|github.com/openwrt/packages|g' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -i "${SDK_DIR}"/feeds.conf.default
echo "src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall" >>"${SDK_DIR}"/feeds.conf.default
echo "src-git liuran001 https://github.com/liuran001/openwrt-packages;packages" >>"${SDK_DIR}"/feeds.conf.default

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
# Refer to https://github.com/openwrt/packages/blob/master/net/shadowsocks-libev/Makefile
# sed -i -e 's/^PKG_VERSION:=.*/PKG_VERSION:=3.3.5/g' \
#     -e 's/^PKG_RELEASE:=.*/PKG_RELEASE:=1/g' \
#     -e 's/^PKG_HASH:=.*/PKG_HASH:=cfc8eded35360f4b67e18dc447b0c00cddb29cc57a3cec48b135e5fb87433488/g' feeds/packages/net/shadowsocks-libev/Makefile

./scripts/feeds update -i
./scripts/feeds install -a

if [[ -d ${LEAN_DIR} ]]; then
    [ -d package/lean ] && rm -fr package/lean
    cp -R "${LEAN_DIR}/package/lean/" package/
fi
if [[ -d ${LIENOL_DIR} ]]; then
    cp -R "${LIENOL_DIR}/package/lean" package/lean/
fi
if [[ -d ${SMARTDNS_DIR} ]]; then
    mkdir -p package/smartdns
    cp -pr "${SMARTDNS_DIR}/package/openwrt" package/smartdns
    sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=1.2020.05.04/g' \
        -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=0005/g' \
        -e 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:=770ce9e8bc502b2769f897676df9495129fb3afa/g' \
        package/smartdns/openwrt/Makefile
fi
for pkg in package/lean/*; do
    pkg=$(basename "${pkg}")
    # find feeds/lienol -type d -iname "$pkg"
    if [[ -d package/feeds/lienol/${pkg} ]]; then
        rm -fr "package/lean/${pkg}"
        # rm -fr "package/feeds/lienol/${pkg}"
    fi
done

[ -d package/fw876 ] && rm -fr package/fw876
mkdir -p package/fw876
temp_dir=$(mktemp -d)
rm -fr "${temp_dir}"
git clone https://github.com/fw876/helloworld.git "${temp_dir}"
mv "${temp_dir}"/* package/fw876/
unset -v temp_dir

[ -d package/kuoruan ] && rm -fr package/kuoruan
# git clone https://github.com/kuoruan/luci-app-v2ray.git package/kuoruan/luci-app-v2ray
# git clone https://github.com/kuoruan/openwrt-v2ray.git package/kuoruan/openwrt-v2ray
# sed -i -e 's/PKG_NAME:=v2ray-core/PKG_NAME:=v2ray/g' package/kuoruan/openwrt-v2ray/Makefile
# sed -i -e 's/$(PKG_NAME)/v2ray-core/g' package/kuoruan/openwrt-v2ray/Makefile
# [ -d package/feeds/lienol/v2ray ] && rm -fr package/feeds/lienol/v2ray
# [ -d package/lean/v2ray ] && rm -fr package/lean/v2ray

# [ -d package/cokebar ] && rm -fr package/cokebar
# mkdir -p package/cokebar
# git clone https://github.com/cokebar/openwrt-vlmcsd.git package/cokebar/openwrt-vlmcsd
# git clone https://github.com/cokebar/luci-app-vlmcsd.git package/cokebar/luci-app-vlmcsd

[ -d package/jerrykuku ] && rm -fr package/jerrykuku
for _pkg in lua-maxminddb luci-app-vssr; do
    git clone "https://github.com/jerrykuku/${_pkg}.git" package/jerrykuku/${_pkg}
done

rm -fr .config ./tmp
./scripts/feeds install -a
make defconfig

if [[ $(command -v pre_ops) ]]; then pre_ops; fi

make -j"$(nproc)" package/feeds/luci/luci-base/compile

if [[ ${BUILD} -gt 0 ]]; then
    for src_dir in package/feeds/lienol package/lean package/cokebar package/fw876 package/jerrykuku package/kuoruan package/smartdns; do
        for pkg in "${src_dir}"/*; do
            [[ -d ${pkg} ]] || continue
            make -j"$(nproc)" "${pkg}"/compile || true
        done
    done
fi

popd
