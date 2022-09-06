# CC README

```bash
# https://forum.archive.openwrt.org/viewtopic.php?id=65672
ln -s ../feeds/base/package/utils package/utils
sed -i 's%PKG_MIRROR_MD5SUM:=.*%PKG_MIRROR_MD5SUM:=69713ce2793c857ddb277b0bb1d3a7b6%g' feeds/base/package/firmware/linux-firmware/Makefile
```
