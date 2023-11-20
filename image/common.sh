#!/bin/bash

trap _exec_exit_hook EXIT
function _exec_exit_hook() {
    local _idx
    for ((_idx = ${#_EXIT_HOOKS[@]} - 1; _idx >= 0; _idx--)); do
        eval "${_EXIT_HOOKS[_idx]}" || true
    done
}

function _add_exit_hook() {
    while (($#)); do
        _EXIT_HOOKS+=("$1")
        shift
    done
}

function _add_package() {
    local _before=0
    if [[ ${1} == "-b" ]]; then
        _before=1
        shift
    fi
    while (($#)); do
        if [[ ${PACKAGES} != *"${1}"* ]]; then
            if [[ ${_before} -gt 0 ]]; then
                PACKAGES="${1}${PACKAGES:+ ${PACKAGES}}"
            else
                PACKAGES="${PACKAGES:+${PACKAGES} }${1}"
            fi
        fi
        shift
    done
}

function _check_param() {
    while (($#)); do
        if [[ -z ${!1} ]]; then
            echo "\${$1} is required"
            return 1
        fi
        shift 1
    done
}
