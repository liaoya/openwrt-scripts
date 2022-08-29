# README

```bash
gcc -s -o mkhash mkhash.c
sudo mv mkhash /usr/local/bin
sudo cp ipkg-make-index.sh /usr/local/bin
```

```bash
ipkg-make-index.sh . > Packages && gzip -9nc Packages > Packages.gz
```

```bash
./ipkg-util.sh -s /work/openwrt/sdk/ath79 -d /work/openwrt/package/21.02/ath79/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/armvirt -d /work/openwrt/package/21.02/armvirt/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/mt7620 -d /work/openwrt/package/21.02/mt7620/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/mt7621 -d /work/openwrt/package/21.02/mt7621/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/x64 -d /work/openwrt/package/21.02/x64/ -o copy
```

```bash
./ipkg-util-docker.sh -s ../docker/sdk/ath79-nand-21.02.3-bin -d /work/openwrt/package/21.02/ath79/ -o copy
./ipkg-util-docker.sh -s ../docker/sdk/ramips-mt7621-21.02.3-bin -d /work/openwrt/package/21.02/mt7621/ -o copy
./ipkg-util-docker.sh -s ../docker/sdk/x86-64-21.02.3-bin -d /work/openwrt/package/21.02/x64/ -o copy
```
