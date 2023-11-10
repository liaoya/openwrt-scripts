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
rsync -av /work/openwrt/dl/ /mnt/udisk/openwrt/dl/

rsync -av /work/openwrt/package/22.03/ /mnt/udisk/openwrt/package/22.03/
```
