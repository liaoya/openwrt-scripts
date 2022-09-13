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
./ipkg-util.sh -s /work/openwrt/sdk/ath79 -d /work/openwrt/package/21.02/ath79-nand/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/armvirt -d /work/openwrt/package/21.02/armvirt/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/mt7620 -d /work/openwrt/package/21.02/ramips-mt7620/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/mt7621 -d /work/openwrt/package/21.02/ramips-mt7621/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/x64 -d /work/openwrt/package/21.02/x86-64/ -o copy
```

```bash
./ipkg-util-docker.sh list ../docker/sdk/ath79-nand-22.03.0-bin

./ipkg-util-docker.sh copy ../docker/sdk/armvirt-64-22.03.0-bin /work/openwrt/package/22.03/armvirt-64
./ipkg-util-docker.sh copy ../docker/sdk/ath79-nand-22.03.0-bin /work/openwrt/package/22.03/ath79-nand
./ipkg-util-docker.sh copy ../docker/sdk/ramips-mt7620-22.03.0-bin /work/openwrt/package/22.03/ramips-mt7620
./ipkg-util-docker.sh copy ../docker/sdk/ramips-mt7621-22.03.0-bin /work/openwrt/package/22.03/ramips-mt7621
./ipkg-util-docker.sh copy ../docker/sdk/x86-64-22.03.0-bin /work/openwrt/package/22.03/x86-64

./ipkg-util-docker.sh copy ../docker/sdk/ath79-nand-21.02.3-bin /work/openwrt/package/21.02/ath79-nand
./ipkg-util-docker.sh copy ../docker/sdk/ramips-mt7620-21.02.3-bin /work/openwrt/package/21.02/ramips-mt7620
./ipkg-util-docker.sh copy ../docker/sdk/ramips-mt7621-21.02.3-bin /work/openwrt/package/21.02/ramips-mt7621
./ipkg-util-docker.sh copy ../docker/sdk/x86-64-21.02.3-bin /work/openwrt/package/21.02/x86-64
```
