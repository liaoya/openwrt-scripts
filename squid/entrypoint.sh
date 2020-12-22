#!/bin/bash

set -ex

/usr/sbin/squid -z -N
# /usr/sbin/squid --foreground -d 1
/usr/sbin/squid --foreground
