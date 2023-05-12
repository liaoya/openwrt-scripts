#!/bin/bash
#shellcheck disable=SC2312

set -e

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")

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
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -h, show help.
    -b, the bin directory binding for image output. ${BIN_DIR:+The default is '"${BIN_DIR}"'}
    -c, clean build. ${CLEAN:+The default is "${CLEAN}"}
    -d, the dl download directory. ${DL_DIR:+The default is '"${DL_DIR}"'}
    -p, the platform. ${PLATFORM:+The default is '"${PLATFORM}"'}
    -r, dry run. ${DRYRUN:+The default is '"${DRYRUN}"'}
    -v, the openwrt version. ${VERSION:+The default is '"${VERSION}"'}
EOF
}

DL_DIR=${DL_DIR:-/work/openwrt/dl}
VERSION=${VERSION:-"22.03.5"}

while getopts "hb:cd:p:rv:" OPTION; do
    case ${OPTION} in
    h)
        _print_help
        exit 0
        ;;
    c)
        CLEAN=1
        ;;
    b)
        BIN_DIR=$(readlink -f "${OPTARG}")
        ;;
    d)
        DL_DIR=$(readlink -f "${OPTARG}")
        ;;
    p)
        PLATFORM=${OPTARG}
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

_check_param PLATFORM VERSION
MAJOR_VERSION=$(echo "${VERSION}" | cut -d. -f1,2)
DOCKER_IMAGE=docker.io/openwrt/sdk:${PLATFORM}-${VERSION}
docker image pull "${DOCKER_IMAGE}"
if [[ -z ${BIN_DIR} ]]; then BIN_DIR=${THIS_DIR}/${PLATFORM}-${MAJOR_VERSION}-bin; fi
if [[ ${CLEAN} -gt 0 && -d "${BIN_DIR}" ]]; then rm -fr "${BIN_DIR}"; fi
if [[ ! -d "${BIN_DIR}" ]]; then mkdir -p "${BIN_DIR}"; fi

DOCKER_OPTS=(--rm -it -u "$(id -u):$(id -g)" -v "${BIN_DIR}:/home/build/openwrt/bin")
if [[ -d "${DL_DIR}" ]]; then
    DOCKER_OPTS+=(-v "${DL_DIR}:/home/build/openwrt/dl")
fi

for script in build.sh checkout.sh config.sh; do
    DOCKER_OPTS+=(-v "${THIS_DIR}/${script}:/home/build/${script}")
done
if [[ -n ${GIT_PROXY} ]]; then
    DOCKER_OPTS+=(--env GIT_PROXY="${GIT_PROXY}")
fi
DOCKER_OPTS+=(--env "MAJOR_VERSION=${MAJOR_VERSION}")
for item in http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY; do
    if [[ -n ${!item} ]]; then
        DOCKER_OPTS+=(--env "${item}=${!item}")
    fi
done
if [[ $(timedatectl show | grep Timezone | cut -d= -f2) == Asia/Shanghai ]]; then
    DOCKER_OPTS+=(--env DEBIAN_MIRROR=http://mirrors.ustc.edu.cn)
fi

if [[ ${DRYRUN:-0} -eq 0 ]]; then
    docker run "${DOCKER_OPTS[@]}" "${DOCKER_IMAGE}" bash -c '$HOME/checkout.sh; $HOME/config.sh; $HOME/build.sh'
else
    docker run "${DOCKER_OPTS[@]}" "${DOCKER_IMAGE}" bash
fi
