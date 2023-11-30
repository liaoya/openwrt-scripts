#!/bin/bash

set -a

echo -e "#!/bin/sh\n\ncat <<EOF | tee /etc/dropbear/authorized_keys" >>"${CONFIG_TEMP_DIR}/etc/uci-defaults/99_dropbear"
while IFS= read -r -d '' _id_rsa; do
    if ! grep "vagrant insecure public key" "${_id_rsa}"; then
        cat <"${_id_rsa}" >>"${CONFIG_TEMP_DIR}/etc/uci-defaults/99_dropbear"
    fi
done < <(find ~/.ssh \( -iname id_rsa.pub -o -iname id_ed25519.pub \) -print0)
echo -e "EOF\n\nexit 0" >>"${CONFIG_TEMP_DIR}/etc/uci-defaults/99_dropbear"
