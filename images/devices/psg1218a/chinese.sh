#!/bin/bash
#shellcheck disable=SC1090

THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_DIR}")
source "${THIS_DIR}/functions.sh"

#shellcheck disable=SC2034
BASE_URL=https://downloads.openwrt.org/releases/${VERSION}/targets/ramips/mt7620

PACKAGES=""
PACKAGES="${PACKAGES:+$PACKAGES }luci luci-theme-bootstrap luci-i18n-base-zh-cn"

pre_ops() {
    add_wireless_config
}
