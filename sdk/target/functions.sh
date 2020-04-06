#!/bin/bash

function disable_option() {
    local config=$1
    sed -i "s/${config}=y/# ${config} is not set/g" .config
}

function enable_option() {
    local config=$1
    sed -i "s/# ${config} is not set/${config}=y/g" .config
}

function configure_passwall() {
    for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin; do
        disable_option "${config}"
    done

    for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ipt2socks \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_pdnsd \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_socks \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_socks \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray; do
        enable_option "${config}"
    done
}

function configure_ssr_plus() {
    for config in CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Redsocks2 \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray_plugin; do
        disable_option "${config}"
    done

    for config in CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_DNS2SOCKS \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Kcptun \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Simple_obfs \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray; do
        enable_option "${config}"
    done
}

function configure_v2ray() {
    enable_option CONFIG_V2RAY_COMPRESS_GOPROXY
    if [[ -x $(readlink -f staging_dir/host/bin/upx) ]]; then
        enable_option CONFIG_V2RAY_COMPRESS_UPX
    else
        disable_option CONFIG_V2RAY_COMPRESS_UPX
    fi
}
