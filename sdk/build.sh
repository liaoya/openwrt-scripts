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
LEAN_DIR=${LEAN_DIR:-/work/github/coolsnowwolf/lede}
LIENOL_DIR=${LIENOL_DIR:-/work/github/Lienol/openwrt}
SMARTDNS_DIR=${SMARTDNS_DIR:-/work/github/pymumu/smartdns}
NAME=${NAME:-""}
TARGET=${TARGET:-""}
VERSION=${VERSION:-"19.07.2"}
CLEAN=0
MIRROR=0

print_usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
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
        if [[ -n ${NAME} ]]; then
            NAME=$(dirname "${NAME}")
            tar -xf "${CACHE_DIR}/${SDK_FILENAME}" -C "${NAME}"
            NAME=${NAME}/$(basename -s .tar.xz "${SDK_FILENAME}")
            mv "${NAME}" "${SDK_DIR}"
        else
            tar -xf "${CACHE_DIR}/${SDK_FILENAME}" -C "${ROOT_DIR}"
        fi
    fi
fi

if [[ -n ${DL_DIR} ]]; then
    if [[ -d "${SDK_DIR}/dl" ]]; then rm -fr "${SDK_DIR}/dl"; fi
    if [[ ! -h "${SDK_DIR}/dl" ]]; then ln -s "${DL_DIR}" "${SDK_DIR}/dl"; fi
fi

if [[ $(command -v pre_ops) ]]; then pre_ops; fi

[[ -f "${SDK_DIR}"/feeds.conf.default.origin ]] || cp "${SDK_DIR}"/feeds.conf.default "${SDK_DIR}"/feeds.conf.default.origin
[[ -f "${SDK_DIR}"/feeds.conf.default.origin ]] && cp "${SDK_DIR}"/feeds.conf.default.origin "${SDK_DIR}"/feeds.conf.default

sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e 's|git.openwrt.org/feed/packages|github.com/openwrt/packages|g' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -i "${SDK_DIR}"/feeds.conf.default
echo "src-git lienol https://github.com/Lienol/openwrt-package" >> "${SDK_DIR}"/feeds.conf.default

pushd "${SDK_DIR}"
mkdir -p staging_dir/host/bin
if [[ $(command -v upx) ]]; then ln -s "$(command -v upx)" staging_dir/host/bin; fi
if [[ $(command -v upx-ucl) ]]; then ln -s "$(command -v upx-ucl)" staging_dir/host/bin; fi

scripts/feeds clean
./scripts/feeds update -a

# Remove the kcptun in package feed since it's quite old
rm -fr feeds/packages/net/kcptun
# Fail to update node, need investigation
# sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=v12.15.0/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/lang/node/Makefile
sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=3.3.4/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/net/shadowsocks-libev/Makefile

./scripts/feeds update -i
./scripts/feeds install -a

if [[ -d ${LEAN_DIR} ]]; then
    cp -R "${LEAN_DIR}/package/lean/" package/
fi
# if [[ -d ${LIENOL_DIR} ]]; then
#     cp -R "${LIENOL_DIR}/package/lean"/*smartdns* package/lean/
# fi
if [[ -d ${SMARTDNS_DIR} ]]; then
    mkdir -p package/smartdns
    cp -pr "${SMARTDNS_DIR}/package/openwrt" package/smartdns
    sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=1.2020.02.25/g' \
        -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=2212/g' \
        -e 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:=b31792ad9b3ef8c3bf87dd0f8bae0d0a5b5c9122/g' \
        package/smartdns/openwrt/Makefile
fi
for pkg in package/lean/*; do
    pkg=$(basename "${pkg}")
    if [[ -d package/feeds/lienol/${pkg} ]]; then
        # rm -fr "package/lean/${pkg}"
        rm -fr "package/feeds/lienol/${pkg}"
    fi
done
git clone https://github.com/kuoruan/luci-app-v2ray.git package/kuoruan/luci-app-v2ray
rm -f .config ./tmp
./scripts/feeds install -a
make defconfig

for config in CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray_plugin \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Redsocks2 \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server; do
    sed -i "s/${config}=y/# ${config} is not set/g" .config
done

for config in CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Simple_obfs \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Kcptun \
           CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_DNS2SOCKS; do
    sed -i "s/# ${config} is not set/${config}=y/g" .config
done

for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin; do
    sed -i "s/${config}=y/# ${config} is not set/g" .config
done

for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ipt2socks \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_socks \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_socks \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_pdnsd \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks \
           CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs; do
    sed -i "s/# ${config} is not set/${config}=y/g" .config        
done

make -j"$(nproc)" package/feeds/luci/luci-base/compile
for pkg in package/feeds/lienol/*; do
    pkg=$(basename "${pkg}")
    make -j"$(nproc)" package/feeds/lienol/"${pkg}"/compile || true
done
for pkg in package/lean/*; do
    pkg=$(basename "${pkg}")
    if [[ ! -d "package/feeds/lienol/${pkg}" ]]; then
        make -j"$(nproc)" package/lean/"${pkg}"/compile || true
    fi
done
for pkg in package/kuoruan/*; do
    make -j"$(nproc)" "${pkg}"/compile
done
for pkg in package/smartdns/*; do
    make -j"$(nproc)" "${pkg}"/compile
done
popd
