#!/bin/bash

set -e

function build() {
    # build coremark explicitly
    find package -iname "coremark" -print0 | xargs -0 -I % make %/compile 2>/dev/null || true

    for src_dir in package/feeds/*; do
        [[ -d "${src_dir}" ]] || continue
        _build=1
        for official in base freifunk luci packages routing telephony; do
            if [[ ${src_dir} == "package/feeds/${official}" ]]; then
                _build=0
                break
            fi
        done
        if [[ "${_build}" -gt 0 ]]; then
            for pkg in "${src_dir}"/*; do
                _build=1
                [[ -d ${pkg} ]] || continue
                for _skip in node-request openssl1.1 filebrowser luci-app-unblockneteasemusic; do
                    #shellcheck disable=SC2086
                    if [[ "$(basename ${pkg})" == "${_skip}" ]]; then
                        _build=0
                        break
                    fi
                done
                # if [[ "${_build}" -gt 0 ]]; then echo "${pkg}/compile"; fi
                if [[ "${_build}" -gt 0 ]] && ! make -j "${pkg}"/compile 2>/dev/null; then
                    echo "make V=sc ${pkg}/compile" >>build.log
                fi
            done
        fi
    done
}

function build1() {
    src_dir=package/feeds/smpackage
    for pkg in "${src_dir}"/*; do
        _build=1
        [[ -d ${pkg} ]] || continue
        for _skip in node-request openssl1.1 filebrowser luci-app-unblockneteasemusic; do
            #shellcheck disable=SC2086
            if [[ "$(basename ${pkg})" == "${_skip}" ]]; then
                _build=0
                break
            fi
        done
        # if [[ "${_build}" -gt 0 ]]; then echo "${pkg}/compile"; fi
        if [[ "${_build}" -gt 0 ]] && ! make -j "${pkg}"/compile 2>/dev/null; then
            echo "make V=sc ${pkg}/compile" >>build.log
        fi
    done
}

if [[ -f build.log ]]; then
    rm -f build.log
fi
touch build.log
build
mv build.log bin/
