#!/bin/bash

set -e

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")

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

function _check_param() {
    while (($#)); do
        if [[ -z ${!1} ]]; then
            echo "\${$1} is required"
            return 1
        fi
        shift 1
    done
}

version=21.02.3

function _print_help() {
    #shellcheck disable=SC2016
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -h, --help
        Display help text and exit. No other output is generated.
    -c, --clean
        Clean the previous build
    -b, --bindir bindir
        BIN_DIR="<path>" # alternative output directory for the images. ${bindir:+The default is '"${bindir}"'}
    -d, --disableservice disableservice
        DISABLED_SERVICES="<svc1> [<svc2> [<svc3> ..]]" # Which services in /etc/init.d/ should be disabled. ${disableservice:+The default is '"${disableservice}"'}
    -f, --files files
        FILES="<path>" # include extra files from <path>. ${files:+The default is '"${files}"'}
    -n, --name name
        EXTRA_IMAGE_NAME="<string>" # Add this to the output image filename (sanitized). ${name:+The default is '"${name}"'}
    -p, --platform platform
        OpenWRT platform(used for image tag), e.g. armvirt-64, ath79-nand, ramips-mt7621, x86-64. ${platform:+The default is '"${platform}"'}
    -P, --profile profile
        PROFILE="<profilename>" # override the default target profile. ${profile:+The default is '"${profile}"'}
    -t, --thirdparty thirdparty
        Thirdparty package directory. ${thirdparty:+The default is '"${thirdparty}"'}
    -v, --version version
        OpenWRT version(used for image tag). ${version:+The default is '"${version}"'}
EOF
}

TEMP=$(getopt -o b:d:f:n:p:P:t:v:hc --long bindir:,disableservice:,files:,name:,platform:,profile:,thirdparty:,version:,help,clean,dryrun -- "$@")
eval set -- "$TEMP"
while true; do
    shift_step=2
    case "$1" in
    -b | --bindir)
        bindir=$(readlink -f "$2")
        ;;
    -d | --disableservice)
        disableservice=$2
        ;;
    -f | --files)
        files=$(readlink -f "$2")
        ;;
    -n | --name)
        name=$2
        ;;
    -p | --platform)
        platform=$2
        ;;
    -P | --profile)
        profile=$2
        ;;
    -t | --thirdparty)
        thirdparty=$2
        ;;
    -v | --version)
        version=$2
        ;;
    -h | --help)
        _print_help
        exit 0
        ;;
    -c | --clean)
        shift_step=1
        clean=1
        ;;
    --dryrun)
        shift_step=1
        dryrun=1
        ;;
    --)
        shift
        break
        ;;
    *)
        _print_help
        exit 1
        ;;
    esac
    shift "${shift_step}"
done

_check_param platform version
if [[ -z ${profile} && ${platform} == "x86-64" ]]; then
    profile=generic
fi
_check_param profile

major_version=$(echo "${version}" | cut -d. -f1,2)
if [[ -z ${bindir} ]]; then
    bindir=${THIS_DIR}/${platform}-${profile}-${version}-bin
    if [[ ${clean:-0} -gt 0 ]] && [[ -d "${bindir}" ]]; then
        rm -fr "${bindir}"
    fi
    if [[ ! -d ${bindir} ]]; then mkdir -p "${bindir}"; fi
fi
if [[ -z ${files} ]]; then
    files=${THIS_DIR}/config/${major_version}/${platform}/${profile}
    if [[ ! -d "${files}" ]]; then
        mkdir -p "${files}"
    fi
fi

docker_image_name=docker.io/openwrtorg/imagebuilder:${platform}-${version}
docker image pull "${docker_image_name}"
docker_opts=(--rm -it -u "$(id -u):$(id -g)")
if [[ $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
    OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://mirrors.ustc.edu.cn/openwrt}
    cmd=${cmd:+${cmd}; }"sed -i -e 's|http://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g' -e 's|https://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g' repositories.conf"
fi
for item in http_proxy https_proxy no_proxy; do
    if [[ -n ${!item} ]]; then
        docker_opts+=(--env "${item}=${!item}")
    fi
done
if [[ -n ${bindir} ]]; then
    docker_opts+=(-v "${bindir}:/home/build/openwrt/bin")
fi
if [[ -d ${files} ]]; then
    if [[ -f "${THIS_DIR}/config/${major_version}/99_common" ]]; then
        mkdir -p "${files}/etc/uci-defaults"
        cp "${THIS_DIR}/config/${major_version}/99_common" "${files}/etc/uci-defaults/"
        _add_exit_hook "rm -f ${files}/etc/uci-defaults/99_common"
    fi
    docker_opts+=(-v "${files}:/home/build/openwrt/custom")
fi
if [[ -n ${thirdparty} ]]; then
    docker_opts+=(-v "${thirdparty}:/home/build/openwrt/thirdparty")
    cmd="${cmd:+${cmd}; }sed -i -e '\|^## Place your custom repositories here.*|a src custom file:///home/build/openwrt/thirdparty' -e 's/^option check_signature$/# &/' repositories.conf"
fi
if [[ ${platform} == "x86-64" ]]; then
    PACKAGES="${PACKAGES:+${PACKAGES} }kmod-dax kmod-dm"
fi

makecmd="make image"
if [[ -n ${files} ]]; then
    makecmd="${makecmd} FILES=/home/build/openwrt/custom"
fi
if [[ -n ${name} ]]; then
    makecmd="${makecmd} EXTRA_IMAGE_NAME=${name}"
fi
if [[ -n ${PACKAGES} ]]; then
    makecmd="${makecmd} PACKAGES=\"${PACKAGES}\""
fi
if [[ -n ${profile} ]]; then
    makecmd="${makecmd} PROFILE=${profile}"
fi
if [[ ${dryrun:-0} -eq 0 ]]; then
    docker run "${docker_opts[@]}" "${docker_image_name}" bash -c "${cmd}; ${makecmd}"
else
    echo "${makecmd}"
    docker run "${docker_opts[@]}" "${docker_image_name}" bash -c "${cmd}; bash"
fi

# qemu-img convert to make the image as thin provision, do not compress it any more to make backing file across pool
if [[ $(command -v qemu-img) && ${platform} == "x86-64" && ${dryrun:-0} -eq 0 ]]; then
    while IFS= read -r _gz_image; do
        _prefix=$(dirname "${_gz_image}")
        _img=${_prefix}/$(basename -s .gz "${_gz_image}")
        _qcow=${_prefix}/$(basename -s .img.gz "${_gz_image}").qcow2c
        if [[ -f "${_qcow}" ]]; then
            continue
        fi
        if [[ ! -f "${_img}" ]]; then
            gunzip -k "${_gz_image}" || true
        fi
        qemu-img convert -c -O qcow2 "${_img}" "${_qcow}"
        qemu-img convert -O qcow2 "${_qcow}" "${_img}" # Ventoy use img
        unset -v _prefix _img _qcow
    done < <(find "${bindir}/targets/x86/64" -iname "*-combined*.img.gz" | grep -v efi | sort)
fi
