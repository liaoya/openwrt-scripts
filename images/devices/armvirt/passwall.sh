#!/bin/bash
# This script has not been passed

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")
#shellcheck disable=SC1090
source "${THIS_DIR}/custom.sh"

PACKAGES="${PACKAGES:+$PACKAGES }luci-app-adbyby luci-i18n-adbyby-plus-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-autoreboot luci-i18n-autoreboot-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-smartdns luci-i18n-smartdns-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-passwall"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn"

pre_ops() {
    if [[ -d "${HTTP_FOLDER}" ]]; then
    #shellcheck disable=SC2164
        (cd "${HTTP_FOLDER}"; nohup python3 -m http.server 8080 1>/dev/null 2>&1 &)
        for repo in "src/gz reboot_sdk_base http://localhost:8080/base" \
                    "src/gz reboot_sdk_luci http://localhost:8080/luci" \
                    "src/gz reboot_sdk_package http://localhost:8080/packages" \
                    "src/gz reboot_sdk_lienol http://localhost:8080/lienol"; do
            repo=$(echo "${repo}" | sed 's/\//\\\//g')
            sed -i "/telephony$/a ${repo}" repositories.conf
        done
    fi
}

post_ops() {
    pkill -9 python3
}
