# libvirt

```bash
virsh pool-define-as --name default --type dir --target /var/lib/libvirt/images/
virsh pool-start default
virsh pool-autostart default

virsh pool-refresh default
virsh vol-list default

POOL=default
_POOL_PATH=$(virsh pool-dumpxml "${POOL}" | xmllint --xpath "string(//pool/target/path)" -)

back_image=$(sudo find "${_POOL_PATH}" -iname "immortalwrt-*-generic-squashfs-combined.img" -printf "%T@ %p\n" | sort -r | head -1 | cut -d" " -f2)
capacity=$(virsh vol-dumpxml ${back_image} | xmllint --xpath "string(//volume/capacity)" -)

vm_name=immortalwrt
virsh destroy ${vm_name}; virsh undefine --remove-all-storage ${vm_name}

virsh vol-create-as --pool default --name ${vm_name}.qcow2 --format qcow2 --capacity ${capacity} --backing-vol ${back_image} --backing-vol-format qcow2
if ! virsh list --name --all | grep -s -q "${vm_name}"; then
   virt-install --name="${vm_name}" --memory=512 --vcpus=1 --os-variant=linux2022 --cpu host \
                --disk path="${_POOL_PATH}/${vm_name}.qcow2",bus=virtio \
                --network bridge=br0,model=virtio \
                --import --noautoconsole
fi
```

```bash
uci set dhcp.lan.ignore=1
#disable IPV6
uci delete dhcp.lan.dhcpv6
uci delete dhcp.lan.ra
uci delete dhcp.lan.ra_management
uci delete dhcp.lan.ra_default
uci commit dhcp
/etc/init.d/dnsmasq restart

uci set network.lan.ipaddr='192.168.1.5'
uci set network.lan.gateway='192.168.1.1'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.dns='192.168.1.1'
uci delete network.lan.type
uci commit network
/etc/init.d/network restart

touch /etc/firewall.user
for rule in "iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" \
    "iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53" \
    "iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53"; do
    if ! grep -s -q "${rule}" /etc/firewall.user; then
        echo "${rule}" >>/etc/firewall.user
    fi
done
/etc/init.d/firewall restart
```

```bash
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci
```
