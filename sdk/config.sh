#!/bin/bash
#shellcheck disable=SC2312

set -e

function disable_option() {
    local config=$1
    sed -i -e "s/${config}=y/# ${config} is not set/g" -e "s/${config}=m/# ${config} is not set/g" .config
}

function enable_option() {
    local config=$1
    sed -i "s/# ${config} is not set/${config}=y/g" .config
}

function module_option() {
    local config=$1
    sed -i "s/# ${config} is not set/${config}=m/g" .config
}

function common_luci_work() {
    local name=CONFIG_PACKAGE_luci-app-$1
    local option

    module_option "${name}"

    while IFS= read -r option; do
        disable_option "${option}"
    done < <(grep "${name}_" .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort)

    name=CONFIG_PACKAGE_luci-i18n-$1-
    while IFS= read -r option; do
        enable_option "${option}"
    done < <(grep "${name}" .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort)
}

# grep -e 'luci-app-bypass\|luci-i18n-bypass' .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_bypass() {
    local option

    common_luci_work bypass

    for option in \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Kcptun \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Shadowsocks_Libev_Client \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Simple_Obfs \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_V2ray_plugin \
        CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Xray; do
        enable_option "${option}"
    done
}

# grep -i passwall .config | grep -v passwall2 | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_passwall() {
    local option

    common_luci_work passwall

    for config in \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Rust_Client \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Simple_Obfs \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray_Plugin; do
        enable_option "${config}"
    done
}

# grep -i passwall2 .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_passwall2() {
    local option

    common_luci_work passwall2

    for config in \
        CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Rust_Client \
        CONFIG_PACKAGE_luci-app-passwall2_INCLUDE_Simple_Obfs \
        CONFIG_PACKAGE_luci-app-passwall2_INCLUDE_V2ray_Plugin; do
        enable_option "${config}"
    done
}

# grep -i ssr-plus .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_ssr_plus() {
    local option

    common_luci_work ssr-plus

    for config in \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ChinaDNS_NG \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Kcptun \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Client \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Simple_Obfs \
        CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray; do
        enable_option "${config}"
    done
}

# grep -i vssr .config | grep -v vssr-plus | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_vssr() {
    local option

    common_luci_work vssr

    for config in \
        CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Kcptun \
        CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray \
        CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray_plugin; do
        enable_option "${config}"
    done
}

# grep -i vssr-plus .config | sed -e 's/=m//g' -e 's/=y//g' -e 's/^# //g' -e 's/ is not set//g' | sort
function configure_vssr_plus() {
    local option

    common_luci_work vssr-plus
}

rm -fr tmp

configure_bypass
configure_passwall
configure_passwall2
configure_ssr_plus
configure_vssr
