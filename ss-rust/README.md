# README

## ShadowSocks Server

```bash
# The following is optional
rm -f .options

# start the container
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= bash run.sh start server

env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= bash run.sh -p xray-plugin -m "mode=grpc" start server
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= SHADOWSOCKS_SERVER= SIP003_PLUGIN=xray-plugin SIP003_PLUGIN_OPTS=mode=grpc bash run.sh start server

# stop and remove the container
bash run.sh clean server
```

## ShadowSocks Client

```bash
# The following is optional
rm -f .options

# start the container
env SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= SHADOWSOCKS_SERVER= bash run.sh -p xray-plugin -m "mode=grpc" start client

# stop and remove the container
bash run.sh clean client
```

## KCP client

```bash
# The following is optional
rm -f .options

# start the container
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= SHADOWSOCKS_SERVER= bash run.sh -p xray-plugin -m "mode=grpc" start kcp
env KCPTUN_PORT= SHADOWSOCKS_PASSWORD= SHADOWSOCKS_PORT= SHADOWSOCKS_SERVER= SIP003_PLUGIN= SIP003_PLUGIN_OPTS= bash run.sh start kcp

# stop and remove the container
bash run.sh clean kcp
```

Run `curl --proxy "http://localhost:1080" -Lv http://httpbin.org/get` test

## `.options` Examples

```text
kcptun_port=23399
kcptun_version=v20210624
shadowsocks_password=
shadowsocks_port=22314
shadowsocks_rust_version=v1.14.3
shadowsocks_server=
#sip003_plugin_opts=mode=grpc
#sip003_plugin=xray-plugin
xray_plugin_version=v1.5.7
```

```bash
# Open a port
sudo ufw allow 8388

# Show the status
sudo ufw status numbered

# delete a rule
sudo ufw delete 4
```

The kcp options are <https://hub.docker.com/r/horjulf/kcptun> or <https://hub.docker.com/r/playn/kcptun>.
