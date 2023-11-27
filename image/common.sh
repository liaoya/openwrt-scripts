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

function _thin_provision() {
    # qemu-img convert to make the image as thin provision, do not compress it any more to make backing file across pool
    if command -v qemu-img 1>/dev/null 2>&1 && [[ ${TARGET} == "x86-64" && ${DRYRUN:-0} -eq 0 ]]; then
        while IFS= read -r _gz_image; do
            _prefix=$(dirname "${_gz_image}")
            _img=${_prefix}/$(basename -s .gz "${_gz_image}")
            _qcow=${_prefix}/$(basename -s .img.gz "${_gz_image}").qcow2c
            if [[ -f "${_qcow}" && ${_gz_image} != *"squashfs"* ]] || [[ -f "${_img}" && ${_gz_image} == *"squashfs"* ]]; then
                continue
            fi
            if [[ ! -f "${_img}" ]]; then
                gunzip -k "${_gz_image}" || true
            fi
            # Ventoy use img
            if [[ ${_gz_image} == *"squashfs"* ]]; then
                qemu-img convert -O qcow2 "${_img}" "${_qcow}"
                mv "${_qcow}" "${_img}"
            else
                qemu-img convert -c -O qcow2 "${_img}" "${_qcow}"
                qemu-img convert -O qcow2 "${_qcow}" "${_img}"
            fi
            unset -v _prefix _img _qcow
        done < <(find "${BINDIR}/targets/x86/64" -iname "*-combined*.img.gz" | grep -v efi | sort)
    fi
}
