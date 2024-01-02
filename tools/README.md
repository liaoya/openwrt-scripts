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
sudo mount -o uid=$(id -u) -o gid=$(id -g) /dev/sdb1 /mnt/usb
alias ls="ls --color=none"

rsync -aq --no-acls --no-perms --no-xattrs /work/openwrt/ /mnt/usb/openwrt/
rsync -aq --no-acls --no-perms --no-xattrs /work/immortalwrt/ /mnt/usb/immortalwrt/
```

```bash
find . -type d -exec chmod 755 {} \;

find . -type f -exec chmod 644 {} \;

mkdir -p /work/openwrt/package/23.05/{ath79-nand,armsr-armv8,ramips-mt7621,x86-64}

mkdir -p /work/openwrt/package/21.02/{ath79-nand,armvirt-64,ramips-mt7621,x86-64}

python3 make-index.py -i /work/openwrt/package

python3 make-index.py -i /work/immortalwrt/package
```

```bash
python3 remove-oldpkg.py -r /work/openwrt/package/ -v

python3 remove-oldpkg.py -r /work/immortalwrt/package/ -v
```
