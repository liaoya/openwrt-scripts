#!/bin/bash

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

if [[ -z ${SHADOWSOCKS_SERVER} ]]; then
    #shellcheck disable=SC2016
    echo 'Please assign ${SHADOWSOCKS_SERVER}'
    exit 1
fi

if [[ ! -f "${THIS_DIR}/ss-local.json" ]]; then
    envsubst "$(env | sort | sed -e 's/=.*//' -e 's/^/\$/g')" <"${THIS_DIR}/ss-local-tpl.json" | tee "${THIS_DIR}/ss-local.json"
    if [[ -n ${SIP003_PLUGIN} ]]; then
        jq --arg value "${SIP003_PLUGIN}" '.servers[0] |= . + {plugin: $value}' "${THIS_DIR}/ss-local.json" |
            jq --arg value "${SIP003_PLUGIN_OPTS}" '.servers[0] |= . + {plugin_opts: $value}' |
            jq -S . | sponge "${THIS_DIR}/ss-local.json"
    fi
fi
