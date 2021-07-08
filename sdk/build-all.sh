#!/bin/bash

set -ex

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

function build() {
    for src_dir in package/feeds/*; do
        [[ -d "${src_dir}" ]] || continue
        _build=1
        for official in base luci packages routing telephony; do
            if [[ ${src_dir} == "package/feeds/$official" || ${src_dir} == "package/feeds/$official/" ]]; then
                _build=0
                break
            fi
        done
        if [[ "${_build}" -gt 0 ]]; then
            for pkg in "${src_dir}"/*; do
                [[ -d ${pkg} ]] || continue
                make -j"$(nproc)" "${pkg}"/compile || true
            done
        fi
    done
}

unset -v PIP_REQUIRE_VIRTUALENV
unset -v GOPROXY

bash "${THIS_DIR}"/setup.sh -d /work/openwrt/dl -n /work/openwrt/sdk/armvirt -t armvirt "$@"
(
    cd /work/openwrt/sdk/armvirt
    build
)
bash "${THIS_DIR}"/setup.sh -t /work/openwrt/dl -n /work/openwrt/sdk/x64 -t x64 "$@"
(
    cd /work/openwrt/sdk/x64
    build
)
bash "${THIS_DIR}"/setup.sh -d /work/openwrt/dl -n /work/openwrt/sdk/mt7621 -t mt7621 "$@"
(
    cd /work/openwrt/sdk/mt7621
    build
)
bash "${THIS_DIR}"/setup.sh -d /work/openwrt/dl -n /work/openwrt/sdk/mt7620 -t mt7620 "$@"
(
    cd /work/openwrt/sdk/mt7620
    build
)
bash "${THIS_DIR}"/setup.sh -d /work/openwrt/dl -n /work/openwrt/sdk/ar71xx -t ar71xx "$@"
(
    cd /work/openwrt/sdk/ar71xx
    build
)
