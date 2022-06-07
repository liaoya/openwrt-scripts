#!/bin/bash

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

if [[ ! -f "${THIS_DIR}/ssserver-rust.json" ]]; then
    envsubst "$(env | sort | sed -e 's/=.*//' -e 's/^/\$/g')" <"${THIS_DIR}/ssserver-rust-tpl.json" | tee "${THIS_DIR}/ssserver-rust.json"
    if [[ -n ${SIP003_PLUGIN} ]]; then
        jq --arg value "${SIP003_PLUGIN}" '. + {plugin: $value}' "${THIS_DIR}/ssserver-rust.json" |
            jq --arg value "${SIP003_PLUGIN_OPTS}" '. + {plugin_opts: $value}' |
            jq -S . | sponge "${THIS_DIR}/ssserver-rust.json"
    fi
fi
