#!/bin/bash

if [[ -n ${BASE_URL_PREFIX} ]]; then
#shellcheck disable=SC2034
    BASE_URL=${BASE_URL_PREFIX}/releases/${VERSION}/targets/ar71xx/nand
fi