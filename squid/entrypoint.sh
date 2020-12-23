#!/bin/bash

set -ex

if [[ -n ${CLEAN} ]] && [[ ${CLEAN^^} == "TRUE" || ${CLEAN^^} == "YES" || ${CLEAN^^} -ge 1 ]]; then
    rm -fr /var/cache/squid/*
fi

/usr/sbin/squid -z -N

if [[ -n ${LOG_LEVEL} ]]; then
    /usr/sbin/squid --foreground -d "${LOG_LEVEL}"
else
    /usr/sbin/squid --foreground
fi
