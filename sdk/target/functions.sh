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
function configure_passwall() {
    return 0
    for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Server; do
        disable_option "${config}"
    done

    for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ipt2socks \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_NaiveProxy \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_pdnsd \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_socks \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_socks \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin; do
        enable_option "${config}"
    done
}

function configure_ssr_plus() {
    # shellcheck disable=SC2043
    for config in CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server; do
        disable_option "${config}"
    done

    for config in CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Kcptun \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_NaiveProxy \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Redsocks2 \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Simple_obfs \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray_plugin; do
        enable_option "${config}"
    done
}

function configure_v2ray() {
    if [[ -x $(readlink -f staging_dir/host/bin/upx) ]]; then
        enable_option CONFIG_V2RAY_COMPRESS_UPX
    else
        disable_option CONFIG_V2RAY_COMPRESS_UPX
    fi
}

function configure_vssr() {
    for config in CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_ShadowsocksR_Server \
        CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_ShadowsocksR_Socks; do
        disable_option "${config}"
    done

    for config in CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Kcptun \
        CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Trojan \
        CONFIG_PACKAGE_luci-app-vssr_INCLUDE_V2ray \
        CONFIG_PACKAGE_luci-app-vssr_INCLUDE_V2ray_plugin; do
        enable_option "${config}"
    done
}

function configure_vssr-plus() {
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
