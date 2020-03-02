#!/bin/bash
#
# Run this script to make every shell file is valid

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

[[ $(command -v shellcheck) ]] || { echo "Cannot find shellcheck"; exit 1; }

SHELLCHECK_RESULT="true"

function run_shellcheck() {
    local _this_dir
    if [[ -d ${1} ]]; then
        while IFS= read -r -d '' shellfile
        do
            run_shellcheck "${shellfile}"
        done < <(find "${1}" -iname "*.sh" -print0)
    else
        _this_dir=$(dirname "${1}")
        if [[ ! -f "${_this_dir}/.shellcheck.disable" && ! -f "${_this_dir}/.${1}.shellcheck.disable" ]]; then
            shellcheck "${1}" || SHELLCHECK_RESULT="false"
        fi
    fi
}

if [[ $(command -v git) ]]; then git clean -X -f; fi

if [[ $# -eq 0 ]]; then
    run_shellcheck "${THIS_DIR}"
else
    while (( $# )); do
        target=$(readlink -f "${1}"); shift;
        run_shellcheck "${target}"
    done
fi

[[ ${SHELLCHECK_RESULT} == true ]] || exit 1
