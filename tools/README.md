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

```bash
find . -type f -iname "*oaf*.ipk" -exec cp {} /work/immortalwrt/package/21.02/armvirt-64/ \;

find . -type d -exec chmod 755 {} \;

find . -type f -exec chmod 644 {} \;

python3 make-index.py -i /work/openwrt/package

python3 make-index.py -i /work/immortalwrt/package
```
