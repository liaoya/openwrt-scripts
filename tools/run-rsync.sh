#!/bin/bash

set -e

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
DEST=${DEST:-/work}

function _print_help() {
    cat <<EOF
$(basename "${BASH_SOURCE[0]}") OPTIONS
    -h, show the help
    -v, verbose mode
    -d DEST
        the root directory. ${DEST:+the default is ${DEST}}
    -s SRC
        the input directory contain ipk built. ${SRC:+the default is ${SRC}}
EOF
}

while getopts :hvd:s: OPTION; do
    case ${OPTION} in
    h)
        _print_help
        exit 0
        ;;
    v)
        set -x
        export PS4='+(${BASH_SOURCE[0]}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
        ;;
    d)
        DEST=$(readlink -f "${OPTARG}")
        ;;
    s)
        SRC=$(readlink -f "${OPTARG}")
        ;;
    *)
        _print_help
        exit 1
        ;;
    esac
done

for name in SRC DEST; do
    if [[ -z ${!name} || ! -d ${!name} ]]; then
        echo "${name} has no value or its value is illegal"
        exit 1
    fi
done

if [[ ! -d "${SRC}/packages" ]]; then
    echo "${SRC}/packages does not exists"
    exit 1
fi

DISTRIBUTION=$(basename "${SRC}" | cut -d- -f1)
TARGET=$(basename "${SRC}" | sed -e "s/${DISTRIBUTION}-//" -e 's/-bin//' | rev | cut -d- -f2- | rev)
VERSION=$(basename "${SRC}" | sed -e "s/${DISTRIBUTION}-//" -e 's/-bin//' | rev | cut -d- -f1 | rev)

DEST=${DEST}/${DISTRIBUTION,,}/package/${VERSION}/${TARGET}

if [[ ! -d "${DEST}" ]]; then mkdir -p "${DEST}"; fi

find "${SRC}" -type f -iname "kmod-oaf*.ipk" -exec cp {} "${DEST}" \;

#shellcheck disable=SC2010
while IFS= read -r _folder; do
    if ! basename "${_folder}" | grep -qs -e 'base\|packages\|luci\|routing\|telephony'; then
        rsync -aq "${_folder}"/ "${DEST}"/
    fi
done < <(find "${SRC}"/packages -type d | sort | tail +3)

python3 "${THIS_DIR}"/make-index.py -i "${DEST}"
