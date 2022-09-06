#!/bin/bash

_tmp_dir=$(mktemp -d)

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

function install_upx() {
    if [[ -x /usr/local/bin/upx ]]; then
        local _dir _machine _url UPX_VERSION
        UPX_VERSION=$(curl -sL "${CURL_OPTS[@]}" https://api.github.com/repos/upx/upx/releases/latest | jq -r .tag_name)
        UPX_VERSION=${UPX_VERSION:-v3.96}
        _machine=$(uname -m)
        if [[ ${_machine} == "x86_64" ]]; then
            _url="https://github.com/upx/upx/releases/download/${UPX_VERSION}/upx-${UPX_VERSION:1}-amd64_linux.tar.xz"
        elif [[ ${_machine} == "aarch64" ]]; then
            _url="https://github.com/upx/upx/releases/download/${UPX_VERSION}/upx-${UPX_VERSION:1}-arm64_linux.tar.xz"
        fi
        curl -sL "${_url}" -o - | tar -C "${_tmp_dir}" -I xz -xf -
        _dir=$(basename -s .tar.xz "${_url}")
        mv "${_tmp_dir}/${_dir}"/upx /usr/local/bin
        rm -fr "${_tmp_dir:?}"/*
    fi
    cp /usr/local/bin/upx staging_dir/host/bin/upx
}
