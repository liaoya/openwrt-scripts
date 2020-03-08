#!/bin/bash

if [[ -n ${BASE_URL_PREFIX} ]]; then
#shellcheck disable=SC2034
    BASE_URL="${BASE_URL_PREFIX}/releases/${VERSION}/targets/x86/64"
fi