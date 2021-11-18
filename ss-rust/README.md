# README

## Server

```bash
# start the container
bash run.sh start server

# stop and remove the container
bash run.sh clean server
```

## Client

```bash
export SHADOWSOCK_SERVER=204.44.71.56

# start the container
bash run.sh start client

# stop and remove the container
bash run.sh clean client

curl --proxy "http://localhost:1080" -Lv http://httpbin.org/get
```

## KCP

```bash
export SHADOWSOCK_SERVER=204.44.71.56

# start the container
bash run.sh start kcp

# stop and remove the container
bash run.sh clean kcp

curl --proxy "http://localhost:1080" -Lv http://httpbin.org/get
```
