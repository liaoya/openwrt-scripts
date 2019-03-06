#!/bin/bash
#
# Run this script to make every shell file is valid

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

[[ $(command -v shellcheck) ]] || { echo "Cannot find shellcheck"; exit 1; }

SHELLCHECK_RESULT="true"

run_shellcheck() {
    while IFS= read -r -d '' shellfile
    do
        shellcheck "${shellfile}" || SHELLCHECK_RESULT="false"
    done < <(find "${1}" -iname "*.sh" -print0)
}

if [[ $# -eq 0 ]]; then
    run_shellcheck "${THIS_DIR}"
else
    while (( "$#")); do
        target_dir=$1; shift;
        [[ -d "${target_dir}" ]] && run_shellcheck "${target_dir}"
    done
fi

[[ ${SHELLCHECK_RESULT} == true ]] || exit 1
