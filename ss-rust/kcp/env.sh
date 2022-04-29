#!/bin/bash

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

_check_param KCPTUN_PORT SHADOWSOCKS_PASSWORD SHADOWSOCKS_SERVER

if [[ ! -f "${THIS_DIR}/kcptun-client.json" ]]; then
    envsubst "$(env | sort | sed -e 's/=.*//' -e 's/^/\$/g')" <"${THIS_DIR}/kcptun-client-tpl.json" | tee "${THIS_DIR}/kcptun-client.json"
fi

if [[ ! -f "${THIS_DIR}/ss-local.json" ]]; then
    envsubst "$(env | sort | sed -e 's/=.*//' -e 's/^/\$/g')" <"${THIS_DIR}/ss-local-tpl.json" | tee "${THIS_DIR}/ss-local.json"
fi
