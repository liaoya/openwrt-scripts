#!/bin/bash
#shellcheck disable=SC2034

set -ae

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

ROOT_DIR=$(readlink -f "${BASH_SOURCE[0]}")
ROOT_DIR=$(dirname "${ROOT_DIR}")
CACHE_DIR="${HOME}/.cache/openwrt"
mkdir -p "${CACHE_DIR}"

BASE_URL=${BASE_URL:-""}
DISTRIBUTION=${DISTRIBUTION:-OpenWRT}
DRYRUN=${DRYRUN:-0}
OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-""}
if [[ -d /work/openwrt/dl ]]; then
    DL_DIR=${DL_DIR:-/work/openwrt/dl}
else
    DL_DIR=${DL_DIR:-""}
fi
NAME=${NAME:-""}
TARGET=${TARGET:-""}
VERSION=${VERSION:-"23.05.0"}
CLEAN=0

function _print_help() {
    #shellcheck disable=SC2016
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -d, --dl
        the global dl directory, the default value "${DL_DIR}"
    --distribution DISTRIBUTION
        OpenWRT or ImmortalWrt. ${DISTRIBUTION:+The default is '"${DISTRIBUTION}"'}
    -n, --name
        the name of uncompress folder, some build will fail if the name is too long.
    -t, --target
        CPU Arch
    -v, --version
        OpenWRT or ImmortalWrt version. ${VERSION:+The default is '"${VERSION}"'}
    -c, --clean
        clean build. ${CLEAN:+The default is '"${CLEAN}"'}
    --dryrun
        Only kick start the shell, skip the final build step. ${DRYRUN:+The default is '"${DRYRUN}"'}
    -h, --help
        show help
    --verbose
        More information
EOF
}

TEMP=$(getopt -o d:n:t:v:ch --long dl:,distribution:,name:,target:,version:,clean,dryrun,help,verbose -- "$@")
eval set -- "$TEMP"
while true; do
    shift_step=2
    case "$1" in
    -d | --dl)
        DL_DIR=$(readlink -f "$2")
        ;;
    --distribution)
        DISTRIBUTION=$2
        ;;
    -n | --name)
        NAME=$(readlink -f "$2")
        ;;
    -t | --target)
        TARGET=$2
        ;;
    -v | --version)
        #shellcheck disable=SC2034
        VERSION=$2
        ;;
    -c | --clean)
        shift_step=1
        CLEAN=1
        ;;
    -h | --help)
        _print_help
        exit 0
        ;;
    --verbose)
        shift_step=1
        set -x
        export PS4='+(${BASH_SOURCE[0]}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
        ;;
    --dryrun)
        shift_step=1
        DRYRUN=1
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

if [[ $# -eq 0 ]]; then
    echo "No custom feed"
    exit 1
fi

if [[ $(command -v pyenv) ]] && ! pyenv versions | grep -F '* 3.10'; then
    #shellcheck disable=SC2046
    pyenv local $(pyenv versions | grep "3.10.")
fi
_check_param VERSION TARGET

MAJOR_VERSION=$(echo "${VERSION}" | cut -d. -f1,2)
MAJOR_VERSION_NUMBER=$(echo "${MAJOR_VERSION} * 100 / 1" | bc)
if [[ ${MAJOR_VERSION_NUMBER} -lt 2102 ]]; then
    echo "SDK is too old"
    exit 1
fi
if [[ ${DISTRIBUTION,,} == openwrt ]]; then
    if [[ $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
        OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://mirrors.ustc.edu.cn/openwrt}
    else
        OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://downloads.openwrt.org}
    fi
fi
if [[ ${DISTRIBUTION,,} == immortalwrt ]]; then
    if [[ $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
        OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-http://mirror.sjtu.edu.cn/immortalwrt}
    else
        OPENWRT_MIRROR_PATH=${OPENWRT_MIRROR_PATH:-downloads.immortalwrt.org}
    fi
fi

BASE_URL=${OPENWRT_MIRROR_PATH}/releases/${VERSION}/targets
IFS='-' read -r -a array <<<"${TARGET}"
for item in "${array[@]}"; do
    BASE_URL=${BASE_URL}/${item}
done

_TEMP_DIR=$(mktemp -d)
_add_exit_hook "rm -fr ${_TEMP_DIR}"
curl -sL "${BASE_URL}/sha256sums" -o "${_TEMP_DIR}/sha256sums"

SHA256_VALUE=$(grep "${DISTRIBUTION,,}-sdk" "${_TEMP_DIR}/sha256sums" | cut -d' ' -f1)
SDK_FILENAME=$(grep "${DISTRIBUTION,,}-sdk" "${_TEMP_DIR}/sha256sums" | cut -d'*' -f2)
if [[ -f "${CACHE_DIR}/${SDK_FILENAME}" ]]; then
    if [[ $(sha256sum "${CACHE_DIR}/${SDK_FILENAME}" | cut -d' ' -f1) != "${SHA256_VALUE}" ]]; then
        rm -f "${CACHE_DIR}/${SDK_FILENAME}"
    fi
fi

if [[ ! -f "${CACHE_DIR}/${SDK_FILENAME}" ]]; then
    curl -sL "${BASE_URL}/${SDK_FILENAME}" -o "${CACHE_DIR}/${SDK_FILENAME}"
fi

if [[ -n ${NAME} ]]; then
    SDK_DIR=${NAME}
else
    SDK_DIR=$(basename -s .tar.xz "${SDK_FILENAME}")
    SDK_DIR=${ROOT_DIR}/${SDK_DIR}
fi
#shellcheck disable=SC2046
mkdir -p $(dirname "${SDK_DIR}")
if [[ ${CLEAN} -gt 0 && -d "${SDK_DIR}" ]]; then rm -fr "${SDK_DIR}"; fi
if [[ ! -d "${SDK_DIR}" ]]; then
    if [[ -n ${NAME} ]]; then
        NAME=$(dirname "${NAME}")
        tar -xf "${CACHE_DIR}/${SDK_FILENAME}" -C "${NAME}"
        NAME=${NAME}/$(basename -s .tar.xz "${SDK_FILENAME}")
        mv "${NAME}" "${SDK_DIR}"
    else
        tar -xf "${CACHE_DIR}/${SDK_FILENAME}" -C "${ROOT_DIR}"
    fi
fi

if [[ -n ${DL_DIR} ]]; then
    if [[ -d "${SDK_DIR}/dl" ]]; then rm -fr "${SDK_DIR}/dl"; fi
    if [[ ! -L "${SDK_DIR}/dl" ]]; then ln -s "${DL_DIR}" "${SDK_DIR}/dl"; fi
fi

[[ -f "${SDK_DIR}"/feeds.conf.default.origin ]] || cp "${SDK_DIR}"/feeds.conf.default "${SDK_DIR}"/feeds.conf.default.origin
[[ -f "${SDK_DIR}"/feeds.conf.default.origin ]] && cp "${SDK_DIR}"/feeds.conf.default.origin "${SDK_DIR}"/feeds.conf.default

while (($#)); do
    echo "$1" >>"${SDK_DIR}"/feeds.conf.default
    shift
done

pushd "${SDK_DIR}"

if [[ ${DRYRUN} -lt 1 ]]; then
    "${ROOT_DIR}/../checkout.sh"
    "${ROOT_DIR}/../config.sh"
    "${ROOT_DIR}/../build.sh"
fi

popd
