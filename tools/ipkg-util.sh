#!/bin/bash
#shellcheck disable=SC2206

set -e

DEST=${DEST:-""}
OPERATION=${OPERATION:-"list"}
SRC=${SRC:-""}

function _print_help() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]
OPTIONS
    -d, --dest, the dest directory for ipk
    -h, --help, show help
    -o, --operation, the value is copy or list
    -s, --src, the src directory of openwrt build
EOF
}

TEMP=$(getopt -o d:ho:s: --long dest:,help,operation:,src: -- "$@")
eval set -- "$TEMP"
while true; do
    case "$1" in
    -d | --dest)
        shift
        if [[ ! -d ${1} ]]; then
            mkdir -p "${1}"
        fi
        DEST=$(readlink -f "$1")
        ;;
    -h | --help)
        _print_help
        exit 0
        ;;
    -o | --operation)
        shift
        OPERATION=$1
        ;;
    -s | --src)
        shift
        SRC=$(readlink -f "$1")
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
    shift
done

if [[ ! -d "${SRC}/bin" ]]; then
    echo "${SRC} does not exist or is illegal"
    exit 1
fi

declare -a PACKAGES=()

for src_dir in "${SRC}"/package/feeds/*; do
    [[ -d "${src_dir}" ]] || continue
    _build=1
    for official in base freifunk luci packages routing telephony; do
        if [[ ${src_dir} == "${SRC}/package/feeds/$official" || ${src_dir} == "${SRC}/package/feeds/$official/" ]]; then
            _build=0
            break
        fi
    done
    if [[ "${_build}" -gt 0 ]]; then
        for pkg in "${src_dir}"/*; do
            [[ -d ${pkg} ]] || continue
            pkg=$(basename "${pkg}")
            PACKAGES=(${PACKAGES[@]} "${pkg}")
            if [[ ${pkg} =~ luci-app* ]]; then
                pkg=${pkg/luci-app/luci-i18n}
                PACKAGES=(${PACKAGES[@]} "${pkg}")
            fi
        done
    fi
done

declare -a INGNORE_PACKAGES=(openssl1.1)
declare __PACKAGES=()
for name in "${PACKAGES[@]}"; do
    for ignore in "${INGNORE_PACKAGES[@]}"; do
        if [[ ${name} != "${ignore}" ]]; then
            __PACKAGES+=(${name})
        fi
    done
done
PACKAGES=(${__PACKAGES[@]} shadowsocks-libev smartdns v2ray xray)
unset __PACKAGES
# echo ${PACKAGES[@]} | tr ' ' '\n'

if [[ ${OPERATION} == "list" ]]; then
    for name in "${PACKAGES[@]}"; do
        while IFS= read -r -d '' pkg; do
            ls -1 "${pkg}"
        done < <(find "${SRC}/bin" -iname "*$name*.ipk" -print0)
    done
elif [[ ${OPERATION} == "copy" ]]; then
    if [[ ! -d ${DEST} ]]; then
        echo "${DEST} does not exist"
        exit 1
    fi
    for name in "${PACKAGES[@]}"; do
        while IFS= read -r -d '' pkg; do
            cp -pr "${pkg}" "${DEST}"
        done < <(find "${SRC}/bin" -iname "*$name*.ipk" -print0)
    done
    (
        cd "${DEST}"
        rm -fr libopenssl*
        ipkg-make-index.sh . >Packages && gzip -9nc Packages >Packages.gz
    )
else
    echo "Unknown operaiton ${OPERATION}"
    exit 1
fi

# if [[ ${OPERATION} == "list" ]]; then
#     while IFS= read -r -d '' pkg; do
#         _name=$(dirname "${pkg}")
#         _name=$(basename "${_name}")
#         _ignore=0
#         for official in base freifunk luci packages routing telephony; do
#             if [[ ${_name} == "${official}" ]]; then
#                 _ignore=1
#             fi
#         done
#         if [[ ${_ignore} -eq 0 ]]; then
#             ls -1 "${pkg}"
#         fi
#     done < <(find "${SRC}/bin" -iname "*.ipk" -print0 | sort)
#     # find "${SRC}/bin" -iname "*.ipk" | grep -v /'base/' | grep -v /'base/' | grep -v '/luci/' | grep -v '/routing/' | grep -v '/telephony/' | grep -v '/64/packages/' | grep -v -e "${SRC}/bin/packages/.*/packages/.*"
# elif [[ ${OPERATION} == "copy" ]]; then
#     if [[ ! -d ${DEST} ]]; then
#         mkdir -p "${DEST}"
#     fi
#     while IFS= read -r -d '' pkg; do
#         _name=$(dirname "${pkg}")
#         _name=$(basename "${_name}")
#         _ignore=0
#         for official in base freifunk luci packages routing telephony; do
#             if [[ ${_name} == "${official}" ]]; then
#                 _ignore=1
#             fi
#         done
#         if [[ ${_ignore} -eq 0 ]]; then
#             cp "${pkg}" "${DEST}"/
#         fi
#     done < <(find "${SRC}/bin" -iname "*.ipk" -print0 | sort)
#     (
#         cd "${DEST}"
#         ipkg-make-index.sh . >Packages && gzip -9nc Packages >Packages.gz
#     )
# fi
