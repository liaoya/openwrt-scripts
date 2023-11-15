#!/bin/bash

# cut -d" " -f3 openwrt-armsr-armv8-23.05-bin/fail.log | cut -d/ -f4 | tr -t '\n' ' '
declare -a FAILURE_PACKAGES=(adguardhome airconnect alist amule-dlp ariang asterisk-chan-quectel cloudflared dns-proxy fibocom_QMI_WWAN frp homebox joker luci-app-adguardhome luci-app-airconnect luci-app-amule luci-app-aria2 luci-app-bypass luci-app-frpc luci-app-frps luci-app-homebox luci-app-kodexplorer luci-app-netspeedtest luci-app-nginx-manager luci-app-npc luci-app-nps luci-app-pcimodem luci-app-smartdns luci-app-spdmodem luci-app-speedtest-web luci-app-unblockmusic luci-app-usbmodem luci-app-webd luci-app-wifidog luci-app-xunyou)

declare -a SLOW_PACKAGES=()
SLOW_PACKAGES+=(ariang asterisk-chan-quectel cloudreve)
SLOW_PACKAGES+=(libtorrent-rasterbar)
SLOW_PACKAGES+=(luci-app-cd8021x luci-app-easymesh luci-app-music-remote-center luci-app-qbittorrent luci-app-qbittorrent-simple luci-app-rtorrent luci-app-squid)
SLOW_PACKAGES+=(naiveproxy)
SLOW_PACKAGES+=(trojan trojan-plus)

function build_one_dir() {
    local _build
    #shellcheck disable=SC2012
    while IFS= read -r pkg; do
        _build=1
        pkg=$(basename "${pkg}")
        for item in "${FAILURE_PACKAGES[@]}"; do
            if [[ ${item} == "${pkg}" ]]; then
                _build=0
                break
            fi
        done
        for item in "${SLOW_PACKAGES[@]}"; do
            if [[ ${item} == "${pkg}" ]]; then
                _build=0
                break
            fi
        done
        if [[ ${_build} -lt 1 ]]; then
            continue
        fi
        while IFS= read -r -d '' pkg_path; do
            start=$(date +%s)
            if ! make -j "${pkg_path}"/compile 2>/dev/null; then
                echo "make V=sc ${pkg_path}/compile" >>bin/fail.log
            else
                echo "${pkg}" >>bin/sucess.log
            fi
            end=$(date +%s)
            echo "It took $((end - start)) seconds to build ${pkg}" >>bin/bench.log
        done < <(find package -iname "${pkg}" -print0)
    done < <(ls -d "${1}"/*/ | sort)
}

function build() {
    while IFS= read -r feedname; do
        build_one_dir "feeds/${feedname}"
    done < <(./scripts/feeds list -n | grep -v -e 'base\|packages\|luci\|routing\|telephony')
}

for _file in bench.log fail.log sucess.log; do
    if [[ -f "bin/${_file}" ]]; then
        rm -f "bin/${_file}"
    fi
done

build
