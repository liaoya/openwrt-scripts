#!/bin/bash

set -a

if [[ -n ${PPPOE_USERNAME} && -n ${PPPOE_PASSWORD} ]]; then
    cat <<EOF | tee "${CONFIG_TEMP_DIR}/etc/uci-defaults/99_pppoe"
#!/bin/sh

set -e

uci -q batch <<-EOI >/dev/null
delete network.wan.proto
set network.wan.proto='pppoe'
set network.wan.username='${PPPOE_USERNAME}'
set network.wan.password='${PPPOE_PASSWORD}'
# set network.wan.ipv6='0'
commit network.wan

# delete dhcp.wan.ra_flags
# add_list dhcp.wan.ra_flags='none'
# commit dhcp.wan
EOI

exit 0
EOF
fi
