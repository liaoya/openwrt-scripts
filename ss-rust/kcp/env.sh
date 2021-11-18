#!/bin/bash

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

if [[ -z ${SHADOWSOCK_SERVER} ]]; then
    #shellcheck disable=SC2016
    echo 'Please assign ${SHADOWSOCK_SERVER}'
    exit 1
fi

if [[ ! -f "${THIS_DIR}/kcptun-client.json" ]]; then
    envsubst "$(env | sort | sed -e 's/=.*//' -e 's/^/\$/g')" <"${THIS_DIR}/kcptun-client-tpl.json" | tee "${THIS_DIR}/kcptun-client.json"
fi

if [[ ! -f "${THIS_DIR}/ss-local.json" ]]; then
    envsubst "$(env | sort | sed -e 's/=.*//' -e 's/^/\$/g')" <"${THIS_DIR}/ss-local-tpl.json" | tee "${THIS_DIR}/ss-local.json"
fi
