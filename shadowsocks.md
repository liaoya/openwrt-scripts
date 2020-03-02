# Shadowsocks Configuration

Incomplete

```bash
wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/chinadns_chnroute.txt

uci add_list shadowsocks.@access_control[0].wan_fw_ips=8.8.8.8
uci add_list shadowsocks.@access_control[0].wan_fw_ips=8.8.4.4
uci add_list shadowsocks.@access_control[0].wan_bp_ips=107.182.27.19
uci add_list shadowsocks.@access_control[0].wan_bp_ips=185.201.227.49
uci changes
uci commit
```

### Enable dns-forwarder

```bash
uci set dns-forwarder.@dns-forwarder[0].enable=1
uci set dns-forwarder.@dns-forwarder[0].listen_addr='0.0.0.0'
uci set dns-forwarder.@dns-forwarder[0].listen_port='5300'
uci set dns-forwarder.@dns-forwarder[0].dns_servers='8.8.8.8'
uci changes
uci commit
```

### Enable ChinaDNS

```bash
uci set chinadns.@chinadns[0].enable=1
uci set chinadns.@chinadns[0].server='114.114.114.114,127.0.0.1:5300'
uci changes
uci commit
```

### Change dhcp dnsmasq

```bash
uci set dhcp.@dnsmasq[0].nohosts=1
uci set dhcp.@dnsmasq[0].noresolv=1
uci set dhcp.@dnsmasq[0].local=127.0.0.1#5353
uci changes
uci commit
```