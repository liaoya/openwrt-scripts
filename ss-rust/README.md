# README

This repo help to setup a Shadowsocks proxy support

- kcptun (Use this for `CN2` VPS)
- sip003 (xray-plugin)

## ShadowSocks Server

The server will always start with a kcptun service, sip003 is optional

```bash
# Clean the environment (optional)
rm -f .options

# start the service with sip003, this is prefer
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= bash run.sh -p xray-plugin -m "mode=grpc" start server
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= SHADOWSOCKS_SERVER= SIP003_PLUGIN=xray-plugin SIP003_PLUGIN_OPTS=mode=grpc bash run.sh start server

# start the service
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= bash run.sh start server

# stop and remove the service
bash run.sh clean server
```

## ShadowSocks Client

```bash
# Clean the environment (optional)
rm -f .options

# start the service with sip003, this is prefer
env SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= SHADOWSOCKS_SERVER= bash run.sh -p xray-plugin -m "mode=grpc" start client
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= SHADOWSOCKS_SERVER= SIP003_PLUGIN=xray-plugin SIP003_PLUGIN_OPTS=mode=grpc bash run.sh start client

# start the service
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= bash run.sh start client

# stop and remove the service
bash run.sh clean client
```

## KCP client

```bash
# The following is optional
rm -f .options

# start the service with sip003, this is prefer
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= SHADOWSOCKS_SERVER= bash run.sh -p xray-plugin -m "mode=grpc" start kcp
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= SHADOWSOCKS_SERVER= SIP003_PLUGIN=xray-plugin SIP003_PLUGIN_OPTS=mode=grpc bash run.sh start kcp

# start the service
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= bash run.sh start client

# stop and remove the container
bash run.sh clean kcp
```

Run `curl --proxy "http://localhost:1080" -Lv http://httpbin.org/get` test

If you met any issues, try to run the following to clean any configurations

```bash
bash run.sh clean client; bash run.sh clean kcp; bash run.sh clean server
```

## `.options` Examples

Setup server at first, then copy `.options` to client side, add `shadowsocks_server`

```text
kcptun_port=23399
kcptun_version=v20210624
shadowsocks_password=
shadowsocks_port=22314
shadowsocks_rust_version=v1.14.3
#shadowsocks_server=
#sip003_plugin_opts=mode=grpc
#sip003_plugin=xray-plugin
v2ray_plugin_version=v1.3.1
xray_plugin_version=v1.5.7
```

Enable ufw on Ubuntu server and open the port for Shadowsocks

```bash
# Open a port
sudo ufw allow 8388

# Show the status
sudo ufw status numbered

# delete a rule
sudo ufw delete 4
```

## Reference

- <https://github.com/teddysun/xray-plugin>
- <https://github.com/shadowsocks/v2ray-plugin>

The kcp options are <https://hub.docker.com/r/horjulf/kcptun> or <https://hub.docker.com/r/playn/kcptun>.
