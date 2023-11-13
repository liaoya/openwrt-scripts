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

function _check_param() {
    while (($#)); do
        if [[ -z ${!1} ]]; then
            echo "\${$1} is required"
            return 1
        fi
        shift 1
    done
}

function _print_help() {
    #shellcheck disable=SC2016
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS] <addtional feed> ...
OPTIONS
    -h, show help.
    -b BIN_DIR, the bin directory binding for image output. ${BIN_DIR:+The default is '"${BIN_DIR}"'}
    -c DL_DIR, the dl download directory. ${DL_DIR:+The default is '"${DL_DIR}"'}
    -d DISTRIBUTION, OpenWRT or ImmortalWrt. ${DISTRIBUTION:+The default is '"${DISTRIBUTION}"'}
    -t TARGET, the platform. ${TARGET:+The default is '"${TARGET}"'}
    -r, dry run. ${DRYRUN:+The default is '"${DRYRUN}"'}
    -v VERSION, the openwrt version. ${VERSION:+The default is '"${VERSION}"'}
EOF
}

DISTRIBUTION=${DISTRIBUTION:-OpenWRT}
DL_DIR=${DL_DIR:-/work/openwrt/dl}
VERSION=${VERSION:-"23.05.0"}

while getopts "hb:c:d:t:rv:" OPTION; do
    case ${OPTION} in
    h)
        _print_help
        exit 0
        ;;
    b)
        BIN_DIR=$(readlink -f "${OPTARG}")
        ;;
    c)
        DL_DIR=$(readlink -f "${OPTARG}")
        ;;
    d)
        DISTRIBUTION=${OPTARG}
        ;;
    t)
        TARGET=${OPTARG}
        ;;
    r)
        DRYRUN=1
        ;;
    v)
        VERSION=${OPTARG}
        ;;
    *)
        _print_help
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))
if [[ $# -eq 0 ]]; then
    echo "No custom feed"
    exit 1
fi

DISTRIBUTION=${DISTRIBUTION,,}
if [[ ${DISTRIBUTION} != openwrt && ${DISTRIBUTION} != immortalwrt ]]; then
    echo "Only OpenWRT or ImmortalWrt is supported"
fi

_check_param TARGET VERSION
MAJOR_VERSION=$(echo "${VERSION}" | cut -d. -f1,2)
MAJOR_VERSION_NUMBER=$(echo "${MAJOR_VERSION} * 100 / 1" | bc)
_TEMP_DIR=$(mktemp -d)
_add_exit_hook "rm -fr ${_TEMP_DIR}"

if [[ ${DISTRIBUTION} == openwrt ]]; then
    DOCKER_IMAGE=docker.io/openwrt/sdk:${TARGET}-${VERSION}
else
    DOCKER_IMAGE=docker.io/immortalwrt/sdk:${TARGET}-openwrt-${VERSION}
fi
docker image pull "${DOCKER_IMAGE}"
if [[ -z ${BIN_DIR} ]]; then BIN_DIR=${THIS_DIR}/${DISTRIBUTION}-${TARGET}-${MAJOR_VERSION}-bin; fi
if [[ ! -d "${BIN_DIR}" ]]; then mkdir -p "${BIN_DIR}"; fi

MOUNT_DIR=$(docker run --rm -it "${DOCKER_IMAGE}" sh -c "pwd" | tr -d '\r')
SCRIPT_DIR=$(dirname "${MOUNT_DIR}")
if [[ / == "${SCRIPT_DIR}" ]]; then
    SCRIPT_DIR=""
fi

DOCKER_OPTS=(--rm -it -u "$(id -u):$(id -g)" -v "${BIN_DIR}:${MOUNT_DIR}/bin")
if [[ -d "${DL_DIR}" ]]; then
    DOCKER_OPTS+=(-v "${DL_DIR}:${MOUNT_DIR}/dl")
fi

for script in ../build.sh ../checkout.sh ../config.sh; do
    #shellcheck disable=SC2086
    DOCKER_OPTS+=(-v "$(readlink -f ${THIS_DIR}/${script}):${SCRIPT_DIR}/$(basename ${script})")
done
if [[ -n ${GIT_PROXY} ]]; then
    cat <<EOF | tee "${_TEMP_DIR}/.gitconfig"
[url "${GIT_PROXY}"]
    insteadOf = https://
EOF
    DOCKER_OPTS+=(-v "${_TEMP_DIR}/.gitconfig:/builder/.gitconfig")
    if [[ -n ${no_proxy} ]]; then
        no_proxy=${no_proxy}:$(echo "${GIT_PROXY}" | cut -d/ -f3 | cut -d: -f1)
    fi
fi
DOCKER_OPTS+=(--env "MAJOR_VERSION=${MAJOR_VERSION}")
DOCKER_OPTS+=(--env "MAJOR_VERSION_NUMBER=${MAJOR_VERSION_NUMBER}")
for item in http_proxy https_proxy no_proxy; do
    if [[ -n ${!item} ]]; then
        DOCKER_OPTS+=(--env "${item^^}=${!item}")
        DOCKER_OPTS+=(--env "${item}=${!item}")
    fi
done
if [[ -n ${https_proxy} ]]; then
    cat <<EOF | tee "${_TEMP_DIR}/servers"
[global]
http-proxy-host=$(echo "${https_proxy}" | cut -d/ -f3 | cut -d: -f1)
http-proxy-port=$(echo "${https_proxy}" | cut -d/ -f3 | cut -d: -f2)
EOF
    DOCKER_OPTS+=(-v "${_TEMP_DIR}/servers:/builder/.subversion/servers")
fi
if [[ $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
    DOCKER_OPTS+=(--env "GO111MODULE=auto")
    DOCKER_OPTS+=(--env "GOPROXY=https://goproxy.cn,direct")
fi
# GOSU=$(command -v gosu)
# if [[ -n ${GOSU} ]]; then
#     DOCKER_OPTS+=(-v "${GOSU}:/usr/local/bin/gosu:ro")
# fi

cmd="${cmd:+${cmd}; }[ -f feeds.conf.default.origin ] || cp feeds.conf.default feeds.conf.default.origin"
cmd="${cmd:+${cmd}; }cp feeds.conf.default.origin feeds.conf.default"
while (($#)); do
    #shellcheck disable=SC2016
    cmd="${cmd:+${cmd}; echo '$1' >>feeds.conf.default}"
    shift
done

if [[ ${DRYRUN:-0} -eq 0 ]]; then
    docker run "${DOCKER_OPTS[@]}" "${DOCKER_IMAGE}" bash -c "${cmd}; ${SCRIPT_DIR}/checkout.sh; ${SCRIPT_DIR}/config.sh; ${SCRIPT_DIR}/build.sh"
else
    docker run "${DOCKER_OPTS[@]}" "${DOCKER_IMAGE}" bash -c "${cmd}; bash"
fi
