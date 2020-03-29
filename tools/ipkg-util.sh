#!/bin/bash
#shellcheck disable=SC2206

set -e

DEST=${DEST:-""}
OPERATION=${OPERATION:-"list"}
SRC=${SRC:-""}

print_usage() {
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
        DEST=$(readlink -f "$1")
        ;;
    -h | --help)
        print_usage
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
        print_usage
        exit 1
        ;;
    esac
    shift
done

if [[ ! -d "${SRC}/bin" ]]; then
    echo "${SRC} does not exist or is illegal"
    exit 1
fi

# declare -a PACKAGES=(adbyby adguardhome autoreboot brook chinadns-ng coremark dns2socks guest-wifi \
#     haproxy ipt2socks kcptun luci-theme-bootstrap-mod luci-app-vssr maxminddb microsocks \
#     passwall pdnsd redsock ramfree shadowsocks simple-obfs smartdns srelay ssr-plus tcping trojan \
#     unblockmusic UnblockNetease v2ray vlmcsd)

declare -a PACKAGES=()
if [[ -d "${SRC}/package/feeds/lienol" ]]; then
    for pkg in "${SRC}/package/feeds/lienol"/*; do
        pkg=$(basename "${pkg}")
        PACKAGES=(${PACKAGES[@]} "${pkg}")
        if [[ ${pkg} =~ luci-app* ]]; then
            pkg=${pkg/luci-app/luci-i18n}
            PACKAGES=(${PACKAGES[@]} "${pkg}")
        fi
    done
fi
if [[ -d "${SRC}/package/lean" ]]; then
    for pkg in "${SRC}/package/lean"/*; do
        pkg=$(basename "${pkg}")
        if [[ -d "${SRC}/package/lean/${pkg}" ]]; then
            PACKAGES=(${PACKAGES[@]} "${pkg}")
        fi
        if [[ ${pkg} =~ luci-app* ]]; then
            pkg=${pkg/luci-app/luci-i18n}
            PACKAGES=(${PACKAGES[@]} "${pkg}")
        fi
    done
fi
declare -a INGNORE_PACKAGES=(openssl1.1)
declare __PACKAGES=()
for name in "${PACKAGES[@]}"; do
    for ignore in "${INGNORE_PACKAGES[@]}"; do
        if [[ ${name} != "${ignore}" ]]; then
            __PACKAGES+=(${name})
        fi
    done
done
PACKAGES=(${__PACKAGES[@]} shadowsocks-libev smartdns)
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
