# V2Rary Server

The server both support tcp and mkcp protocol, the server support both tcp and mkcp.

The openwrt luci app ShadowSock does not support mkcp `seed`, PassWall does not allow `seed` empty. Consider `teddysun/v2ray` since it update more often.

```bash
curl --proxy http://localhost:1080 -Lv http://httpbin.org/get

curl --proxy http://localhost:1090 -Lv http://httpbin.org/get
```

Change `.options` and run

```bash
./run.sh clean client; ./run.sh start client

./run.sh clean server; ./run.sh start server
```
