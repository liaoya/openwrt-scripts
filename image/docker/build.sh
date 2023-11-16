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

DISTRIBUTION=${DISTRIBUTION:-OpenWRT}
DRYRUN=${DRYRUN:-0}
NOCUSTOMIZE=${NOCUSTOMIZE:-0}
ROOTFS_PARTSIZE=${ROOTFS_PARTSIZE:-0}
VERSION=${VERSION:-23.05.0}

function _print_help() {
    #shellcheck disable=SC2016
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -h, --help
        Display help text and exit. No other output is generated.
    -c, --clean
        Clean the previous build
    -b, --bindir BINDIR
        BIN_DIR="<path>" # alternative output directory for the images. ${BINDIR:+The default is '"${BINDIR}"'}
    --build-dir BUILD_DIR
        the build_dir directory binding for temporary output, cache it for speed build. ${BUILD_DIR:+The default is '"${BUILD_DIR}"'}
    -d, --disableservice DISABLESERVICE
        DISABLED_SERVICES="<svc1> [<svc2> [<svc3> ..]]" # Which services in /etc/init.d/ should be disabled. ${DISABLESERVICE:+The default is '"${DISABLESERVICE}"'}
    --distribution DISTRIBUTION
        OpenWRT or ImmortalWrt. ${DISTRIBUTION:+The default is '"${DISTRIBUTION}"'}
    -f, --files FILES
        FILES="<path>" # include extra FILES from <path>. ${FILES:+The default is '"${FILES}"'}
    -n, --name NAME
        EXTRA_IMAGE_NAME="<string>" # Add this to the output image filename (sanitized). ${NAME:+The default is '"${NAME}"'}
    --nocustomize
        Exclude the common configuration for /etc/uci-defaults. ${NO_CUSTOMIZE:+The default is '"${NO_CUSTOMIZE}"'}
    -p, --profile PROFILE
        PROFILE="<profilename>" # override the default target PROFILE. ${PROFILE:+The default is '"${PROFILE}"'}
    -s, --partsize ROOTFS_PARTSIZE
        ROOTFS_PARTSIZE="<size>" # override the default rootfs partition size in MegaBytes. ${ROOTFS_PARTSIZE:+The default is '"${ROOTFS_PARTSIZE}"'}
    -t, --target TARGET
        OpenWRT TARGET(used for image tag), e.g. armsr-armv8(armvirt-64), ath79-nand, ramips-mt7621, x86-64. ${TARGET:+The default is '"${TARGET}"'}
    -T, --thirdparty THIRDPARTY
        Thirdparty package directory. ${THIRDPARTY:+The default is '"${THIRDPARTY}"'}
    -v, --VERSION VERSION
       OpenWRT or ImmortalWrt version(used for image tag). ${VERSION:+The default is '"${VERSION}"'}
    --verbose
        More information
    --dryrun
        Only kick start the shell, skip the final build step. ${DRYRUN:+The default is '"${DRYRUN}"'}
EOF
}

TEMP=$(getopt -o b:d:f:n:p:s:t:T:v:hc --long bindir:,disableservice:,distribution:,files:,name:,partsize,target:,profile:,thirdparty:,VERSION:,verbose,help,clean,dryrun,nocustomize -- "$@")
eval set -- "${TEMP}"
while true; do
    shift_step=2
    case "$1" in
    -b | --bindir)
        BINDIR=$(readlink -f "$2")
        ;;
    -d | --disableservice)
        DISABLESERVICE=$2
        ;;
    --distribution)
        DISTRIBUTION=$2
        ;;
    -f | --files)
        FILES=$(readlink -f "$2")
        ;;
    -n | --name)
        NAME=$2
        ;;
    -P | --profile)
        PROFILE=$2
        ;;
    -s | --partsize)
        ROOTFS_PARTSIZE=$2
        ;;
    -t | --platform)
        TARGET=$2
        ;;
    -T | --thirdparty)
        THIRDPARTY=$2
        ;;
    -v | --VERSION)
        VERSION=$2
        ;;
    --verbose)
        shift_step=1
        set -x
        export PS4='+(${BASH_SOURCE[0]}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
        ;;
    -h | --help)
        _print_help
        exit 0
        ;;
    -c | --clean)
        shift_step=1
        CLEAN=1
        ;;
    --dryrun)
        shift_step=1
        DRYRUN=1
        ;;
    --nocustomize)
        shift_step=1
        NOCUSTOMIZE=1
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

if [[ -n ${FILES} && ${NOCUSTOMIZE} -gt 0 ]]; then
    echo "${FILES} will not be used as \${NOCUSTOMIZE} is ${NOCUSTOMIZE}"
fi

DISTRIBUTION=${DISTRIBUTION,,}
if [[ ${DISTRIBUTION} != openwrt && ${DISTRIBUTION} != immortalwrt ]]; then
    echo "Only OpenWRT or ImmortalWrt is supported"
fi

_check_param TARGET VERSION
MAJOR_VERSION=$(echo "${VERSION}" | cut -d. -f1,2)
MAJOR_VERSION_NUMBER=$(echo "${MAJOR_VERSION} * 100 / 1" | bc)

if [[ -z ${PROFILE} && ${TARGET} == "x86-64" ]]; then
    if [[ MAJOR_VERSION_NUMBER -le 1907 ]]; then
        PROFILE=Generic
    else
        PROFILE=generic
    fi
fi
if [[ ! ${TARGET} =~ armvirt && ! ${TARGET} =~ armsr ]]; then
    _check_param PROFILE
fi

if [[ -z ${BINDIR} ]]; then
    BINDIR=${THIS_DIR}/${DISTRIBUTION}-${TARGET}${PROFILE:+"-${PROFILE}"}-${VERSION}-bin
fi
if [[ ${CLEAN:-0} -gt 0 ]] && [[ -d "${BINDIR}" ]]; then
    rm -fr "${BINDIR}"
fi
if [[ ! -d ${BINDIR} ]]; then mkdir -p "${BINDIR}"; fi
if [[ ${DISTRIBUTION} == immortalwrt ]]; then
    DOCKER_IMAGE=docker.io/${DISTRIBUTION}/imagebuilder:${TARGET}-openwrt-${VERSION}
else
    DOCKER_IMAGE=docker.io/${DISTRIBUTION}/imagebuilder:${TARGET}-${VERSION}
fi
docker image pull "${DOCKER_IMAGE}"

DOCKER_OPTS=(--rm -it -u "$(id -u):$(id -g)")

_TEMP_DIR=$(mktemp -d)
_add_exit_hook "sudo rm -fr ${_TEMP_DIR}"
mkdir -p "${_TEMP_DIR}/etc/sudoers.d"
echo "build ALL=(ALL) NOPASSWD: ALL" | tee "${_TEMP_DIR}/etc/sudoers.d/build"
sudo chown 0:0 "${_TEMP_DIR}/etc/sudoers.d/build"
DOCKER_OPTS+=(-v "${_TEMP_DIR}/etc/sudoers.d/build:/etc/sudoers.d/build") # Only immortalwrt allow sudo
if [[ -n ${http_proxy} ]]; then
    mkdir -p "${_TEMP_DIR}/etc/apt/apt.conf.d"
    #shellcheck disable=SC2154
    cat <<EOF | sudo tee "${_TEMP_DIR}/etc/apt/apt.conf.d/90curtin-aptproxy"
Acquire::http::proxy "${http_proxy}";
Acquire::https::proxy "${https_proxy}";
EOF
    sudo chown 0:0 "${_TEMP_DIR}/etc/apt/apt.conf.d/90curtin-aptproxy"
    DOCKER_OPTS+=(-v "${_TEMP_DIR}/etc/apt/apt.conf.d/90curtin-aptproxy:/etc/apt/apt.conf.d/90curtin-aptproxy")
fi

if [[ ${DISTRIBUTION} == openwrt && $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
    OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://mirrors.ustc.edu.cn/openwrt}
    cmd=${cmd:+${cmd}; }"sed -i -e 's|http://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g' -e 's|https://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g' repositories.conf"
fi
if [[ ${DISTRIBUTION} == immortalwrt ]]; then
    if [[ $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
        # https://help.mirrors.cernet.edu.cn/immortalwrt
        OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://mirror.sjtu.edu.cn/immortalwrt}
        cmd=${cmd:+${cmd}; }"sed -i -e 's|http://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g' -e 's|https://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g' -e 's|http://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g' -e 's|https://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g' repositories.conf"

        DEBIAN_MIRROR_PATH=${DEBIAN_MIRROR_PATH:-http://mirrors.ustc.edu.cn}
        cmd=${cmd:+${cmd}; }"sudo sed -i -e 's|http://deb.debian.org|${DEBIAN_MIRROR_PATH}|g' -e 's|https://deb.debian.org|${DEBIAN_MIRROR_PATH}|g' /etc/apt/sources.list"
    else
        OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://immortalwrt.kyarucloud.moe/}
    fi
    if [[ ${TARGET} == "x86-64" ]]; then
        cmd=${cmd:+${cmd}; }"sudo apt update -qy; sudo apt install -qy genisoimage" # Fix the missing package
    fi
    if [[ ${TARGET} =~ armvirt || ${TARGET} =~ armsr ]]; then
        cmd=${cmd:+${cmd}; }"sudo apt update -qy; sudo apt install -qy cpio" # Fix the missing package
    fi
fi

if [[ -n ${no_proxy} ]]; then
    no_proxy=${no_proxy//,cn,/,}
fi
for item in http_proxy https_proxy no_proxy; do
    if [[ -n ${!item} ]]; then
        DOCKER_OPTS+=(--env "${item}=${!item}")
        DOCKER_OPTS+=(--env "${item^^}=${!item}")
    fi
done

MOUNT_DIR=$(docker run --rm -it "${DOCKER_IMAGE}" sh -c "pwd" | tr -d '\r')
DOCKER_OPTS+=(-v "${BINDIR}:${MOUNT_DIR}/bin")
if [[ -n ${BUILD_DIR} ]]; then
    if [[ ! -d ${BUILD_DIR} ]]; then
        mkdir -p "${BUILD_DIR}"
    fi
    DOCKER_OPTS=(--rm -it -u "$(id -u):$(id -g)" -v "${BUILD_DIR}:${MOUNT_DIR}/build_dir")
fi

if [[ ${NOCUSTOMIZE:-0} -ne 1 ]]; then
    CONFIG_TEMP_DIR=${_TEMP_DIR}/config
    DOCKER_OPTS+=(-v "${CONFIG_TEMP_DIR}:${MOUNT_DIR}/custom")

    mkdir -p "${CONFIG_TEMP_DIR}/etc/uci-defaults"
    if [[ -d "${FILES}" ]]; then
        cp -p "${FILES}"/* "${CONFIG_TEMP_DIR}"/
    fi
    if [[ -d "${THIS_DIR}/../config/common" ]]; then
        cp -p "${THIS_DIR}/../config/common"/*common "${CONFIG_TEMP_DIR}/etc/uci-defaults/"
    fi
    if [[ -d "${THIS_DIR}/../config/common/${TARGET}/${PROFILE}" ]]; then
        cp -pr "${THIS_DIR}/../config/common/${TARGET}/${PROFILE}"/* "${CONFIG_TEMP_DIR}"/
    fi
    if [[ -d "${THIS_DIR}/../config/${MAJOR_VERSION}" ]]; then
        cp -pr "${THIS_DIR}/../config/${MAJOR_VERSION}"/*common "${CONFIG_TEMP_DIR}/etc/uci-defaults/" || true
    fi
    if [[ -d "${THIS_DIR}/../config/${MAJOR_VERSION}/${TARGET}/${PROFILE}" ]]; then
        cp -pr "${THIS_DIR}/../config/${MAJOR_VERSION}/${TARGET}/${PROFILE}"/* "${CONFIG_TEMP_DIR}"/
    fi
    echo -e "#!/bin/sh\n\ncat <<EOF | tee /etc/dropbear/authorized_keys" >>"${CONFIG_TEMP_DIR}/etc/uci-defaults/10_dropbear"
    while IFS= read -r -d '' _id_rsa; do
        cat <"${_id_rsa}" >>"${CONFIG_TEMP_DIR}/etc/uci-defaults/10_dropbear"
    done < <(find ~/.ssh \( -iname id_rsa.pub -o -iname id_ed25519.pub \) -print0)
    echo -e "EOF\n\nexit 0" >>"${CONFIG_TEMP_DIR}/etc/uci-defaults/10_dropbear"
    if [[ -n ${OPENWRT_MIRROR_PATH} ]]; then
        cat <<EOF | tee "${CONFIG_TEMP_DIR}/etc/uci-defaults/10_opkg"
#!/bin/sh

sed -e 's|http://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g' \
    -e 's|https://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g' \
    -e 's|http://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g' \
    -e 's|https://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g' \
    -e 's|http://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g' \
    -e 's|https://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g' \
    -i /etc/opkg/distfeeds.conf

exit 0
EOF
    fi
fi

if [[ -z ${THIRDPARTY} && -d /work/${DISTRIBUTION}/package/"${MAJOR_VERSION}/${TARGET}" ]]; then
    THIRDPARTY=/work/${DISTRIBUTION}/package/"${MAJOR_VERSION}/${TARGET}"
fi

if [[ -n ${THIRDPARTY} ]]; then
    if [[ ${THIRDPARTY:0:4} == http ]]; then
        cmd="${cmd:+${cmd}; }sed -i -e '\|^## This is the local package repository.*|a src custom ${THIRDPARTY}' -e 's/^option check_signature$/# &/' repositories.conf"
    else
        DOCKER_OPTS+=(-v "${THIRDPARTY}:${MOUNT_DIR}/thirdparty")
        cmd="${cmd:+${cmd}; }sed -i -e '\|^## Place your custom repositories here.*|a src custom file://${MOUNT_DIR}/thirdparty' -e 's/^option check_signature$/# &/' repositories.conf"
    fi
fi
if [[ ${TARGET} == "x86-64" ]]; then
    _add_package kmod-dax kmod-dm
fi

makecmd="make image"
if [[ ${NOCUSTOMIZE:-0} -ne 1 ]]; then
    makecmd="${makecmd} FILES=${MOUNT_DIR}/custom"
fi
if [[ -n ${NAME} ]]; then
    makecmd="${makecmd} EXTRA_IMAGE_NAME=${NAME}"
fi
if [[ -n ${PACKAGES} ]]; then
    makecmd="${makecmd} PACKAGES=\"${PACKAGES}\""
fi
if [[ -n ${PROFILE} ]]; then
    makecmd="${makecmd} PROFILE=${PROFILE}"
fi
if [[ ${TARGET} == x86-64 || ${TARGET} =~ armvirt ]] && [[ ${ROOTFS_PARTSIZE} -gt 0 ]]; then
    makecmd="${makecmd} ROOTFS_PARTSIZE=${ROOTFS_PARTSIZE}"
fi
if [[ ${DRYRUN:-0} -eq 0 ]]; then
    docker run "${DOCKER_OPTS[@]}" "${DOCKER_IMAGE}" bash -c "${cmd:+${cmd};} ${makecmd}"
else
    echo "${makecmd}"
    docker run "${DOCKER_OPTS[@]}" "${DOCKER_IMAGE}" bash -c "${cmd:+${cmd};} bash"
fi

# qemu-img convert to make the image as thin provision, do not compress it any more to make backing file across pool
if [[ $(command -v qemu-img) && ${TARGET} == "x86-64" && ${DRYRUN:-0} -eq 0 ]]; then
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
