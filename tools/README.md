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
find . -type f -iname "kmod-oaf*.ipk" -exec cp {} /work/immortalwrt/package/21.02/armvirt-64/ \;

find . -type d -exec chmod 755 {} \;

find . -type f -exec chmod 644 {} \;

mkdir -p /work/openwrt/package/23.05/{ath79-nand,armsr-armv8,ramips-mt7621,x86-64}

mkdir -p /work/openwrt/package/21.02/{ath79-nand,armvirt-64,ramips-mt7621,x86-64}

python3 make-index.py -i /work/openwrt/package

python3 make-index.py -i /work/immortalwrt/package
```
