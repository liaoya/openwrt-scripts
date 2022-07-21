#!/bin/bash

set -e

function _check_param() {
    while (($#)); do
        if [[ -z ${!1} ]]; then
            echo "\${$1} is required"
            return 1
        fi
        shift 1
    done
}

function disable_option() {
    local config=$1
    sed -i "s/${config}=y/# ${config} is not set/g" .config
}

function enable_option() {
    local config=$1
    sed -i "s/# ${config} is not set/${config}=y/g" .config
}

# Passwall has been remove the source code
# grep -i passwall .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_passwall() {
    for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Haproxy \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_NaiveProxy \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Server \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_GO; do
        disable_option "${config}"
    done
}

# grep -i app-ssr-plus .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_ssr_plus() {
    # shellcheck disable=SC2043
    for config in CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_NaiveProxy \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Libev_Server \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Libev_Server \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Server \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server; do
        disable_option "${config}"
    done

    for config in CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Kcptun \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Libev_Client \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Libev_Client \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Client \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Simple_Obfs \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray_Plugin \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray; do
        enable_option "${config}"
    done
}

function configure_v2ray() {
    if [[ -x $(readlink -f staging_dir/host/bin/upx) ]]; then
        enable_option CONFIG_V2RAY_CORE_COMPRESS_UPX
        enable_option CONFIG_V2RAY_CTL_COMPRESS_UPX
    else
        disable_option CONFIG_V2RAY_CORE_COMPRESS_UPX
        disable_option CONFIG_V2RAY_CTL_COMPRESS_UPX
    fi
}

# grep -i app-vssr-plus .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_vssr_plus() {
    for config in CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_ShadowsocksR_Server \
        CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_ShadowsocksR_Socks; do
        disable_option "${config}"
    done
}

function build() {
    for src_dir in package/feeds/*; do
        [[ -d "${src_dir}" ]] || continue
        _build=1
        for official in base freifunk luci packages routing telephony; do
            if [[ ${src_dir} == "package/feeds/$official" || ${src_dir} == "package/feeds/$official/" ]]; then
                _build=0
                break
            fi
        done
        if [[ "${_build}" -gt 0 ]]; then
            for pkg in "${src_dir}"/*; do
                [[ -d ${pkg} ]] || continue
                for _skip in node-request openssl1.1; do
                    if [[ ${_skip} == "${_skip}" ]]; then
                        break
                    fi
                done
                make -j"$(nproc)" "${pkg}"/compile || true
            done
        fi
    done
}

_check_param MAJOR_VERSION

if [[ -n ${GIT_PROXY} ]]; then
    git config --global url."${GIT_PROXY}".insteadOf https://
fi

sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -i feeds.conf.default
# Change the package definition
sed -e '/^src-git packages http/d' -i feeds.conf.default
echo "src-git packages https://github.com/Lienol/openwrt-packages;${MAJOR_VERSION}" >>feeds.conf.default
{
    echo "src-git Lienol https://github.com/Lienol/openwrt-package"
    echo "src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall"
    echo "src-git fw876 https://github.com/fw876/helloworld"
    echo "src-git kenzok8 https://github.com/kenzok8/openwrt-packages"
    echo "src-git small https://github.com/kenzok8/small"
    echo "src-git jell https://github.com/kenzok8/jell"
    echo "src-git liuran001 https://github.com/liuran001/openwrt-packages;packages"
} >>feeds.conf.default

scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a
rm -fr .config ./tmp
make defconfig

configure_passwall
configure_ssr_plus
configure_v2ray
configure_vssr_plus

build
