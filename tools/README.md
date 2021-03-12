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
./ipkg-util.sh -s /work/ar71xx -d ~/Downloads/package/ar71xx/ -o copy
./ipkg-util.sh -s /work/armvirt -d ~/Downloads/package/armvirt/ -o copy
./ipkg-util.sh -s /work/mt7620 -d ~/Downloads/package/mt7620/ -o copy
./ipkg-util.sh -s /work/mt7621 -d ~/Downloads/package/mt7621/ -o copy
./ipkg-util.sh -s /work/x64 -d ~/Downloads/package/x64/ -o copy
```
