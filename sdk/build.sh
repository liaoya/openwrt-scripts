#!/bin/bash

# cut -d" " -f3 openwrt-armsr-armv8-23.05-bin/fail.log | cut -d/ -f4 | tr -t '\n' ' '
# | tr -t ' ' '\n' | sort | tr -t '\n' ' '
declare -a FAILURE_PACKAGES=()
FAILURE_PACKAGES+=(adguardhome airconnect alist amule-dlp antileech aria2 ariang asterisk-chan-quectel base-files btop cloudflared dae daed dns-proxy dockerd fibocom_QMI_WWAN firewall4 frp fullconenat-nft gallery-dl homebox homeproxy joker luci-app-3ginfo luci-app-3proxy luci-app-acme luci-app-adguardhome luci-app-airconnect luci-app-airplay2 luci-app-alist luci-app-amule luci-app-argone-config luci-app-aria2 luci-app-atinout luci-app-attendedsysupgrade luci-app-autoreboot luci-app-bandwidthd luci-app-broadbandacc luci-app-bypass luci-app-cellled luci-app-clash luci-app-daed luci-app-dawn luci-app-ddns luci-app-design-config luci-app-docker luci-app-dockerman luci-app-e2guardian luci-app-frpc luci-app-frps luci-app-gobinetmodem luci-app-gpoint luci-app-gpsysupgrade luci-app-homebox luci-app-homeproxy luci-app-iptvhelper luci-app-istorex luci-app-keepalived luci-app-kodexplorer luci-app-lxc luci-app-macvlan luci-app-mentohust luci-app-mmconfig luci-app-modeminfo luci-app-mosdns luci-app-multiaccountdial luci-app-mwan3 luci-app-mwan3helper luci-app-natter luci-app-netspeedtest luci-app-nginx-manager luci-app-noddos luci-app-npc luci-app-nps luci-app-olsr-services luci-app-olsr-viz luci-app-packet-capture luci-app-pcimodem luci-app-phtunnel luci-app-samba4 luci-app-smartdns luci-app-smstools3 luci-app-spdmodem luci-app-speedtest-web luci-app-ssr-mudb-server luci-app-store luci-app-syncdial luci-app-syncthing luci-app-unblockmusic luci-app-unishare luci-app-usbmodem luci-app-v2raya luci-app-webd luci-app-wifidog luci-app-xlnetacc luci-app-xunyou luci-app-xwan luci-base luci-mod-network luci-mod-status luci-mod-system my-default-settings natter nps pcat-manager qBittorrent qBittorrent-Enhanced-Edition quickjspp rtl8189es rtl8821cu rtl88x2bu rustdesk-server sagernet-core smartdns speedtest-web subconverter sub-web tuic-server UnblockNeteaseMusic-Go unishare upx upx-static uwsgi v2raya webd xunyou you-get)

declare -a SLOW_PACKAGES=()
SLOW_PACKAGES+=(3ginfo UnblockNeteaseMusic)
SLOW_PACKAGES+=(ariang asterisk-chan-quectel cloudreve filebrowser gmediarender)
SLOW_PACKAGES+=(keepalived libtorrent-rasterbar)
SLOW_PACKAGES+=(luci-app-cd8021x luci-app-diskman luci-app-easymesh luci-app-excalidraw luci-app-filebrowser luci-app-homebridge luci-app-ipsec-server luci-app-ipsec-vpnd luci-app-ipsec-vpnserver-manyusers luci-app-music-remote-center luci-app-ocserv luci-app-penpot luci-app-qbittorrent luci-app-qbittorrent-simple luci-app-rtorrent luci-app-ssrserver-python luci-app-squid luci-app-transmission luci-app-unblockneteasemusic)
SLOW_PACKAGES+=(lux mrtg naiveproxy)
SLOW_PACKAGES+=(pcat-manager qBittorrent qBittorrent-Enhanced-Edition qt6base rtl8189es rtl8821cu rtl88x2bu)
SLOW_PACKAGES+=(trojan trojan-plus ykdl)

function build_one_dir() {
    local _build pkg pkg_path
    #shellcheck disable=SC2012
    while IFS= read -r pkg_path; do
        _build=1
        pkg=$(basename "${pkg_path}")
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
        start=$(date +%s)
        if ! make -j "${pkg_path}"compile 2>/dev/null; then
            echo "make V=sc ${pkg_path}compile" >>bin/fail.log
        else
            echo "${pkg}" >>bin/sucess.log
        fi
        end=$(date +%s)
        echo "It took $((end - start)) seconds to build ${pkg}" >>bin/bench.log
    done < <(ls -d "${1}"/*/ | sort)
}

function build() {
    while IFS= read -r feedname; do
        build_one_dir "package/feeds/${feedname}" || true
    done < <(./scripts/feeds list -n | grep -v -e 'base\|packages\|luci\|routing\|telephony' | sort)
}

for _file in bench.log fail.log sucess.log; do
    if [[ -f "bin/${_file}" ]]; then
        rm -f "bin/${_file}"
    fi
done

build
