#!/bin/bash
#shellcheck disable=SC2312

set -e

function disable_option() {
    local config=$1
    sed -i "s/${config}=y/# ${config} is not set/g" .config
}

function enable_option() {
    local config=$1
    sed -i "s/# ${config} is not set/${config}=y/g" .config
}

# grep app-bypass .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_bypass() {
    for config in CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Shadowsocks_Libev_Server \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_ShadowsocksR_Libev_Server \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Socks_Server \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Trojan; do
        disable_option "${config}"
    done

    for config in CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Kcptun \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_NaiveProxy \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Simple_Obfs \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_V2ray_plugin; do
        enable_option "${config}"
    done
}

# grep -i passwall .config | grep -v passwall2 | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_passwall() {
    for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Haproxy \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_NaiveProxy \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Server \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_GO; do
        disable_option "${config}"
    done

    for config in CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Rust_Client \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray_Plugin; do
        enable_option "${config}"
    done
}

# grep -i passwall2 .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_passwall2() {
    for config in CONFIG_PACKAGE_luci-app-passwall2_INCLUDE_Shadowsocks_Rust_Client \
        CONFIG_PACKAGE_luci-app-passwall2_INCLUDE_V2ray; do
        enable_option "${config}"
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

# grep -i app-vssr .config | grep -v vssr-plus | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_vssr() {
    for config in CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Kcptun \
        CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray \
        CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray_plugin; do
        enable_option "${config}"
    done
}

# grep -i app-vssr-plus .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_vssr_plus() {
    for config in CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_ShadowsocksR_Server \
        CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_ShadowsocksR_Socks; do
        disable_option "${config}"
    done
}

configure_passwall
configure_passwall2
configure_ssr_plus
configure_v2ray
configure_vssr_plus
