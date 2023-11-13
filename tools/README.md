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
rsync -aq /work/openwrt /mnt/usb/
rsync -aq /work/immortalwrt /mnt/usb/
```

`kmod-oaf`
