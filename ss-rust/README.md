# README

## ShadowSocks Server

```bash
# The following is optional
rm -f .options

# The following is optional
export KCPTUN_PORT=29900
export SHADOWSOCKS_PASSWORD=
export SHADOWSOCKS_PORT=8388

# start the container
bash run.sh start server

# stop and remove the container
bash run.sh clean server
```

## ShadowSocks Client

```bash
# The following is optional
rm -f .options

# The following is optional
export SHADOWSOCKS_PASSWORD=
export SHADOWSOCKS_PORT=8388

# The following is mandatory
export SHADOWSOCKS_SERVER=

# start the container
bash run.sh start client

# stop and remove the container
bash run.sh clean client

curl --proxy "http://localhost:1080" -Lv http://httpbin.org/get
```

## KCP client

```bash
# The following is optional
rm -f .options

# The following is optional
export KCPTUN_PORT=29900
export SHADOWSOCKS_PASSWORD=
export SHADOWSOCKS_PORT=8388

# The following is mandatory
export SHADOWSOCKS_SERVER=

# start the container
bash run.sh start kcp

# stop and remove the container
bash run.sh clean kcp

curl --proxy "http://localhost:1080" -Lv http://httpbin.org/get
```

## `.options` Examples

The server examples

```text
kcptun_port=30582
kcptun_version=v20210624
shadowsocks_password=
shadowsocks_port=27782
shadowsocks_rust_version=v1.12.5
```

The client example

```text
kcptun_port=30582
kcptun_version=v20210624
shadowsocks_password=
shadowsocks_port=27782
shadowsocks_rust_version=v1.12.5
shadowsocks_server=
```
