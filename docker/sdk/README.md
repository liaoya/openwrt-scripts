# OpenWrt sdk docker image

```bash
docker run --rm -it -u $(id -u):$(id -g) -v $PWD/bin:/home/build/openwrt/bin docker.io/openwrtorg/sdk:x86_64-21.02.3 bash
```

- `docker.io/openwrtorg/sdk:x86_64-21.02.3`
- `docker.io/openwrtorg/sdk:x86_64-19.07.9`
- `docker.io/openwrtorg/sdk:x86_64-18.06.7`

- `docker.io/openwrtorg/sdk:armvirt-64-21.02.3`
- `docker.io/openwrtorg/sdk:ath79-nand-21.02.3`
- `docker.io/openwrtorg/sdk:ramips-mt7621-21.02.3`
