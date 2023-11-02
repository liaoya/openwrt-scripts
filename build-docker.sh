#!/bin/bash
#shellcheck disable=SC1091,SC2154,SC2312
# VERSION: 0.1.5
# Usage
# Put pre.sh and post.sh in the ${WORK_DIR} folder

# pre.sh examples
# SQUID_VERSION=${SQUID_VERSION:-5.2-r0}
# _image_prefix=docker.io/somebody
# add_image "${_image_prefix}/squid:${SQUID_VERSION}"
# add_image "${_image_prefix}/squid:latest"

# download_url example
# THRIFT_VERSION=${THRIFT_VERSION:-0.17.0}
# download_url "https://dlcdn.apache.org/thrift/${THRIFT_VERSION}/thrift-${THRIFT_VERSION}.tar.gz" thrift
# Does not change HOSTNAME and HTTP_PORT
# THRIFT_URL=http://${HOSTNAME}:${HTTP_PORT}/thrift/thrift-${THRIFT_VERSION}.tar.gz
# for start http server
# export HTTP_FOLDER=${DOCKER_BUILD_CACHE_DIR}

# Multi Dockerfile example
# _this_dir=$(readlink -f "${BASH_SOURCE[0]}")
# _this_dir=$(dirname "${_this_dir}")
# if [[ ${DOCKERFILE} == "${_this_dir}/Dockerfile.ubuntu" ]]; then
# ...
# elif [[ ${DOCKERFILE} == "${_this_dir}/Dockerfile" ]]; then
# ...
# fi
# unset -v _this_dir

set -e

export DOCKER_BUILD_CACHE_DIR=${DOCKER_BUILD_CACHE_DIR:-"${HOME}/.cache/docker/build"}
declare -a DOCKER_BUILD_OPTS=()
export DOCKER_BUILD_OPTS

declare -a _EXIT_HOOKS=()
trap hook::_exec_exit_hook ERR EXIT
function hook::_exec_exit_hook() {
    local _idx
    for ((_idx = ${#_EXIT_HOOKS[@]} - 1; _idx >= 0; _idx--)); do
        eval "${_EXIT_HOOKS[_idx]}" || true
    done
}

function hook::add_exit_hook() {
    while (($#)); do
        _EXIT_HOOKS+=("$1")
        shift
    done
}

function check_command() {
    while (($#)); do
        if ! command -v "${1}" >/dev/null 2>&1; then
            echo "Command ${1} is required"
            exit 1
        fi
        shift
    done
}

function check_dir() {
    while (($#)); do
        if [[ ! -d "${1}" ]]; then
            echo "${1} does not exist"
            exit 1
        fi
        shift
    done
}

function check_file() {
    while (($#)); do
        if [[ ! -f "${1}" ]]; then
            echo "${1} does not exist"
            exit 1
        fi
        shift
    done
}

function check_param() {
    while (($#)); do
        if [[ -z ${!1} ]]; then
            echo "\${$1} is required"
            exit 1
        fi
        shift
    done
}

function concat_docker_build_arg() {
    if [[ $# -eq 1 ]]; then
        if [[ -n ${!1+x} ]]; then
            export DOCKER_BUILD_OPTS+=(--build-arg "${1}=${!1}")
        fi
        # if [[ -n ${!1} ]]; then
        #     export DOCKER_BUILD_OPTS+=(--build-arg "${1}=${!1}")
        # fi
    elif [[ $# -eq 2 ]]; then
        export DOCKER_BUILD_OPTS=(--build-arg "${1}=${2}")
    fi
}

function download_url() {
    local url dest basedir
    url=$1
    shift
    if [[ $# -eq 1 ]]; then
        dest=${DOCKER_BUILD_CACHE_DIR}/$1/$(basename "${url}")
        shift
    else
        dest=${DOCKER_BUILD_CACHE_DIR}/$(basename "${url}")
    fi
    basedir=$(dirname "${dest}")
    if [[ ! -d "${basedir}" ]]; then
        mkdir -p "${basedir}"
    fi
    if [[ ! -f "${dest}" ]]; then
        curl -sL "${url}" -o "${dest}"
    fi
}

# Capture ARG directive in Dockerfile and find it in environtment variables
function handle_build_arg() {
    while IFS= read -r key; do
        concat_docker_build_arg "${key}"
    done < <(sed -e 's/^[ \t]*//' "${1}" | grep '^ARG ' | sed 's/^ARG //g' | cut -d '=' -f 1)
}

function start_http_server() {
    local folder port
    folder=$1
    port=$2
    if command -v python3 >/dev/null 2>&1; then
        eval nohup python3 -m http.server --directory "${folder}" "${port}" >/dev/null 2>&1 &
    elif command -v python2 >/dev/null 2>&1; then
        #shellcheck disable=SC2164
        (
            cd "${folder}"
            eval nohup python2 -m SimpleHTTPServer "${port}" >/dev/null 2>&1 &
        )
    else
        echo "Can't start a http server"
        exit 1
    fi
    hook::add_exit_hook "fuser -k ${port}/tcp"
}

function check_port_used() {
    local port used
    port=$1
    used=0
    if command -v lsof >/dev/null 2>&1; then
        if lsof -i:"${port}" >/dev/null; then used=1; fi
    elif command -v ss >/dev/null 2>&1; then
        if ss -tl | grep -w "${port}"; then used=1; fi
    elif command -v netstat >/dev/null 2>&1; then
        if netstat -tl | grep -w "${port}"; then used=1; fi
    else
        if [[ ! -x /tmp/busybox ]]; then
            curl -sL https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox -o /tmp/busybox
            chmod a+x /tmp/busybox
        fi
        if /tmp/busybox netstat -tl | grep -w "${port}"; then used=1; fi
    fi
    return "${used}"
}

# We always use IP since it's accesible by container
if command -v hostname >/dev/null 2>&1; then
    if hostname -f | grep -s -q "\."; then
        HOSTNAME=$(hostname -f)
    else
        HOSTNAME=$(hostname -I | cut -d " " -f 1)
    fi
elif [[ -f /.dockerenv ]]; then
    # Handle Docker In Docker
    HOSTNAME=$(ip -o -4 addr show eth0 | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
fi

check_command fuser python3

DOCKERFILE=${DOCKERFILE:-""}
declare -a IMAGE_NAME=()
WORK_DIR=${WORK_DIR:-""}
export IMAGE_NAME

function add_image() {
    local find name
    find=0
    for name in "${IMAGE_NAME[@]}"; do
        if [[ ${1} == "${name}" ]]; then
            find=1
        fi
    done
    if [[ ${find} -eq 0 ]]; then
        IMAGE_NAME+=("${1}")
    fi
}

function push_image() {
    for name in "${IMAGE_NAME[@]}"; do
        docker image push "${name}"
    done
}

function remove_image() {
    local find name
    find=0
    for name in "${IMAGE_NAME[@]}"; do
        if [[ ${1} == "${name}" ]]; then
            find=1
        fi
    done
    if [[ ${find} -eq 1 ]]; then
        IMAGE_NAME=("${IMAGE_NAME[@]/${1}/}")
    fi
}

function _print_help() {
    cat <<EOF
$(basename "${BASH_SOURCE[0]}") OPTIONS
    -h, show the help
    -v, verbose mode
    -f, the Dockerfile name, it can be full path. ${DOCKERFILE:+the default is ${DOCKERFILE}}
    -n, the full path as image name including tag, can be multiple.
    -p, push the image to register, need login at first. ${PUSH:+the default is ${PUSH}}
    -w, the working directory for docker build. ${WORK_DIR:+the default is ${WORK_DIR}}
EOF
}

while getopts :hvpf:n:w: OPTION; do
    case ${OPTION} in
    h)
        _print_help
        exit 0
        ;;
    v)
        set -x
        export PS4='+(${BASH_SOURCE[0]}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
        ;;
    p)
        PUSH=1
        ;;
    f)
        DOCKERFILE=$(readlink -f "${OPTARG}")
        ;;
    n)
        add_image "${OPTARG}"
        ;;
    w)
        WORK_DIR=$(readlink -f "${OPTARG}")
        ;;
    *)
        _print_help
        exit 1
        ;;
    esac
done

# Use the Dockerfile under ${WORK_DIR} at first
if [[ -n ${WORK_DIR} && -z ${DOCKERFILE} && -f ${WORK_DIR}/Dockerfile ]]; then
    DOCKERFILE=$(readlink -f "${WORK_DIR}"/Dockerfile)
fi

if [[ -z ${WORK_DIR} && -f ${DOCKERFILE} ]]; then
    WORK_DIR=$(dirname "${DOCKERFILE}")
fi

# Set ${WORK_DIR} if a Dockerilfe found
if [[ -z ${WORK_DIR} && -z ${DOCKERFILE} ]]; then
    if [[ -f "${PWD}/Dockerfile" ]]; then
        DOCKERFILE=$(readlink -f "${PWD}"/Dockerfile)
        WORK_DIR=$(readlink -f "${PWD}")
    elif [[ -f "${THIS_DIR}/Dockerfile" ]]; then
        DOCKERFILE=$(readlink -f "${THIS_DIR}"/Dockerfile)
        WORK_DIR=${THIS_DIR}
    fi
fi

check_param DOCKERFILE WORK_DIR
check_file "${DOCKERFILE}"
check_dir "${WORK_DIR}"
DOCKERFILE_DIR=$(dirname "${DOCKERFILE}")

if [[ -f /tmp/docker_build_port ]]; then
    HTTP_PORT=$(cat /tmp/docker_build_port)
else
    HTTP_PORT=${HTTP_PORT:-54321}
    #shellcheck disable=SC2310
    if ! check_port_used "${HTTP_PORT}"; then
        HTTP_PORT=$((RANDOM % 10000 + 10000))
    fi
    echo "${HTTP_PORT}" >/tmp/docker_build_port # cache the HTTP_PORT so that we can make the build-arg not change
fi
export HTTP_PORT

# source the pre.sh so that it can export some values, e.g. HTTP_FOLDER
# pre.sh can also reset http_proxy, https_proxy and no_proxy
# pre.sh can call download_url to download file in a cached folder
# pre.sh must export HTTP_FOLDER if it need start a python http server for local file for decrease the layer number of image
# pre.sh know the HOSTNAME and HTTP_PORT so that it can provide the url for local files
# pre.sh can set IMAGE_NAME
if [[ -f "${DOCKERFILE_DIR}/pre.sh" ]]; then source "${DOCKERFILE_DIR}/pre.sh"; fi
if [[ ${#IMAGE_NAME[@]} -eq 0 ]]; then
    echo "No image name given"
    exit 1
fi
if [[ -n ${no_proxy} && -n ${HOSTNAME} ]]; then
    no_proxy=${HOSTNAME},${no_proxy}
    #shellcheck disable=SC2034
    NO_PROXY=${no_proxy}
fi
for key in http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY; do
    concat_docker_build_arg "${key}"
done
if [[ -n ${HTTP_FOLDER} ]]; then
    start_http_server "${HTTP_FOLDER}" "${HTTP_PORT}"
fi

handle_build_arg "${DOCKERFILE}"
for name in "${IMAGE_NAME[@]}"; do
    DOCKER_BUILD_OPTS+=(-t "${name}")
done
docker build --force-rm "${DOCKER_BUILD_OPTS[@]}" -f "${DOCKERFILE}" "${WORK_DIR}"

# source the file so that it can export some values
if [[ -f "${DOCKERFILE_DIR}/post.sh" ]]; then
    source "${DOCKERFILE_DIR}/post.sh"
fi

if [[ ${PUSH:-0} -gt 0 ]]; then
    push_image
fi
