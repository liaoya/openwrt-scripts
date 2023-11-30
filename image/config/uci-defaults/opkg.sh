#!/bin/bash

set -a

if [[ -n ${OPENWRT_MIRROR_PATH} ]]; then
    cat <<EOF | tee "${CONFIG_TEMP_DIR}/etc/uci-defaults/10_opkg"
#!/bin/sh

sed -e 's|http://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g' \
    -e 's|https://downloads.openwrt.org|${OPENWRT_MIRROR_PATH}|g' \
    -e 's|http://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g' \
    -e 's|https://downloads.immortalwrt.org|${OPENWRT_MIRROR_PATH}|g' \
    -e 's|http://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g' \
    -e 's|https://mirrors.vsean.net/openwrt|${OPENWRT_MIRROR_PATH}|g' \
    -i /etc/opkg/distfeeds.conf

exit 0
EOF
fi
