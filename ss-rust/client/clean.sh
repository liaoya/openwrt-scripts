#!/bin/bash

set -x

_check_param SHADOWSOCK_SERVER

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

rm -f "${THIS_DIR}/ss-local.json"
