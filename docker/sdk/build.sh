#!/bin/bash

set -e

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
                make -j "${pkg}"/compile || true
            done
        fi
    done
}

build
