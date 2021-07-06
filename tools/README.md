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
./ipkg-util.sh -s /work/openwrt/sdk/ar71xx -d /work/openwrt/package/ar71xx/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/armvirt -d /work/openwrt/package/armvirt/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/mt7620 -d /work/openwrt/package/mt7620/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/mt7621 -d /work/openwrt/package/mt7621/ -o copy
./ipkg-util.sh -s /work/openwrt/sdk/x64 -d /work/openwrt/package/x64/ -o copy
```
