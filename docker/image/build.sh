#!/bin/bash
#shellcheck disable=SC2312

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

PACKAGES=${PACKAGES:-""}

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

version=22.03.4

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
    --nocustomize no_customize
        Exclude the common configuration for /etc/uci-defaults. ${no_customize:+The default is '"${no_customize}"'}
    -p, --platform platform
        OpenWRT platform(used for image tag), e.g. armvirt-64, ath79-nand, ramips-mt7621, x86-64. ${platform:+The default is '"${platform}"'}
    -P, --profile profile
        PROFILE="<profilename>" # override the default target profile. ${profile:+The default is '"${profile}"'}
    -t, --thirdparty thirdparty
        Thirdparty package directory. ${thirdparty:+The default is '"${thirdparty}"'}
    -v, --version version
        OpenWRT version(used for image tag). ${version:+The default is '"${version}"'}
    --dryrun
        Only kick start the shell, skip the final 'make' step
EOF
}

TEMP=$(getopt -o b:d:f:n:p:P:t:v:hc --long bindir:,disableservice:,files:,name:,platform:,profile:,thirdparty:,version:,help,clean,dryrun,nocustomize -- "$@")
eval set -- "${TEMP}"
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
        thirdparty=$(readlink -f "$2")
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
    --nocustomize)
        shift_step=1
        nocustomize=1
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
    if [[ ${version} =~ 19.07 ]]; then
        profile=Generic
    else
        profile=generic
    fi
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

config_temp_dir=$(mktemp -d)
docker_opts+=(-v "${config_temp_dir}:/home/build/openwrt/custom")
_add_exit_hook "rm -fr ${config_temp_dir}"
mkdir -p "${config_temp_dir}/etc/uci-defaults"
if [[ -d "${files}" ]]; then
    cp -p "${files}"/* "${config_temp_dir}"/
fi
if [[ ${nocustomize:-0} -ne 1 ]]; then
    if [[ -d "${THIS_DIR}/config/common" ]]; then
        cp -p "${THIS_DIR}/config/common"/*common "${config_temp_dir}/etc/uci-defaults/"
    fi
    if [[ -d "${THIS_DIR}/config/common/${platform}/${profile}" ]]; then
        cp -pr "${THIS_DIR}/config/common/${platform}/${profile}"/* "${config_temp_dir}"/
    fi
    if [[ -d "${THIS_DIR}/config/${major_version}" ]]; then
        cp -pr "${THIS_DIR}/config/${major_version}"/*common "${config_temp_dir}/etc/uci-defaults/" || true
    fi
    if [[ -d "${THIS_DIR}/config/${major_version}/${platform}/${profile}" ]]; then
        cp -pr "${THIS_DIR}/config/${major_version}/${platform}/${profile}"/* "${config_temp_dir}"/
    fi
    echo -e "#!/bin/sh\n\ncat <<EOF | tee /etc/dropbear/authorized_keys" >>"${config_temp_dir}/etc/uci-defaults/10_dropbear"
    while IFS= read -r -d '' _id_rsa; do
        cat <"${_id_rsa}" >"${config_temp_dir}/etc/uci-defaults/10_dropbear"
    done < <(find ~/.ssh/ -iname id_rsa.pub -print0)
    echo -e "EOF\n\nexit 0" >>"${config_temp_dir}/etc/uci-defaults/10_dropbear"
    if [[ -n ${OPENWRT_MIRROR_PATH} ]]; then
        cat <<EOF | tee "${config_temp_dir}/etc/uci-defaults/10_opkg"
#!/bin/sh

sed -i -e 's|https://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g' -e 's|http://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g' /etc/opkg/distfeeds.conf
# sed -i -e 's|${OPENWRT_MIRROR_PATH}|http://downloads.openwrt.org|g' /etc/opkg/distfeeds.conf

exit 0
EOF
    fi
fi

if [[ -z ${thirdparty} && -d /work/openwrt/package/"${major_version}/${platform}" ]]; then
    thirdparty=/work/openwrt/package/"${major_version}/${platform}"
fi

if [[ -n ${thirdparty} ]]; then
    docker_opts+=(-v "${thirdparty}:/home/build/openwrt/thirdparty")
    cmd="${cmd:+${cmd}; }sed -i -e '\|^## Place your custom repositories here.*|a src custom file:///home/build/openwrt/thirdparty' -e 's/^option check_signature$/# &/' repositories.conf"
fi
if [[ ${platform} == "x86-64" ]]; then
    _add_package kmod-dax kmod-dm
fi

makecmd="make image FILES=/home/build/openwrt/custom"
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
    done < <(find "${bindir}/targets/x86/64" -iname "*-combined*.img.gz" | grep -v efi | sort)
fi
