#!/bin/bash
# This script has not been passed

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")
#shellcheck disable=SC1090
source "${THIS_DIR}/custom.sh"

PACKAGES=${PACKAGES:-""}
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-adbyby luci-i18n-adbyby-plus-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-autoreboot luci-i18n-autoreboot-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-passwall"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-smartdns luci-i18n-smartdns-zh-cn"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-ssr-plus"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn"
