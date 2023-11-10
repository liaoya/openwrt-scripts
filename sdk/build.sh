#!/bin/bash

function build_one_dir() {
    #shellcheck disable=SC2012
    while IFS= read -r pkg; do
        pkg=$(basename "${pkg}")
        while IFS= read -r -d '' pkg_path; do
            if ! make -j "${pkg_path}"/compile 2>/dev/null; then
                echo "make V=sc ${pkg_path}/compile" >>fail.log
            else
                echo "${pkg}" >>sucess.log
            fi
        done < <(find package -iname "${pkg}" -print0)
    done < <(ls -d "${1}"/*/ | sort)
}

function build() {
    while IFS= read -r feedname; do
        build_one_dir "feeds/${feedname}"
    done < <(./scripts/feeds list -n | grep -v -e 'base\|packages\|luci\|routing\|telephony')
}

for _file in fail.log sucess.log; do
    if [[ -f ${_file} ]]; then
        rm -f "${_file}"
    fi
done

build

for _file in fail.log sucess.log; do
    if [[ -f ${_file} ]]; then
        cp "${_file}" bin/
    fi
done
