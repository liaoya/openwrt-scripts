# Using official OpenWRT SDK to build third party package

```bash
sudo apt update -q -y
sudo apt install -y build-essential ccache ecj fastjar file g++ gawk \
    gettext git java-propose-classpath libelf-dev libncurses5-dev \
    libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
    python3-distutils python3-setuptools rsync subversion swig time \
    xsltproc zlib1g-dev
```

## Prepare

Run `git config --global url."http://127.0.0.1:9080/".insteadOf https://` if `git-cache-http-server` installed

- `bash run.sh -d /work/openwrt/dl -n /work/openwrt/sdk/armsr-armv8 -t armsr-armv8 -c "src-git small https://github.com/kenzok8/small"`
  - `bash run.sh -d /work/openwrt/dl -n /work/openwrt/sdk/armvirt-64 -v 22.03.5 -t armvirt-x64 -c "src-git small https://github.com/kenzok8/small"`
- `bash run.sh -d /work/openwrt/dl -n /work/openwrt/sdk/ath79-nand -t ath79-nand -c "src-git small https://github.com/kenzok8/small"`
- `bash run.sh -d /work/openwrt/dl -n /work/openwrt/sdk/ramips-mt7621 -t ramips-mt7621 -c "src-git small https://github.com/kenzok8/small"`
- `bash run.sh -d /work/openwrt/dl -n /work/openwrt/sdk/ramips-mt7620 -t ramips-mt7620 -c "src-git small https://github.com/kenzok8/small"`
- `bash run.sh -t /work/openwrt/dl -n /work/openwrt/sdk/x86-64 -t x86-64 -c "src-git small https://github.com/kenzok8/small"`

- `bash run.sh --distribution ImmortalWrt -t armvirt-64 -v 21.02.7 "src-git small https://github.com/kenzok8/small"`

## Handle Package conflicts

`kcptun` in `lienol` feed will be conflict with that in `package` feed. Refer <https://openwrt.org/docs/guide-developer/feeds>.

```bash
if grep -s -q "src-git xiaorouji" feeds.conf.default; then
    sed -i '/src-git xiaorouji/d' feeds.conf.default
fi
./scripts/feeds update -a
sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=3.3.4/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/net/shadowsocks-libev/Makefile
./scripts/feeds install -a
# Remove kcptun-c and kcptun-s
./scripts/feeds uninstall kcptun
if ! grep -s -q "src-git xiaorouji" feeds.conf.default; then
    echo "src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall" >> feeds.conf.default
fi
./scripts/feeds update -a
./scripts/feeds install -a -p lienol -f -d y
```

```bash
if ! grep -s -q "src-git xiaorouji" feeds.conf.default; then
    echo "src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall" >> feeds.conf.default
fi
./scripts/feeds update -a
# Remove the kcptun in package feed
rm -fr feeds/packages/net/kcptun
sed -i -e 's/PKG_VERSION:=.*/PKG_VERSION:=3.3.4/g' -e 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/net/shadowsocks-libev/Makefile
./scripts/feeds update -i
./scripts/feeds install -a
rm -fr .config ./tmp
make defconfig
```

## Other Packages

- <https://github.com/kuoruan/luci-app-kcptun>
- <https://github.com/kuoruan/luci-app-v2ray>
- <https://github.com/kuoruan/openwrt-kcptun>
- <https://github.com/kuoruan/openwrt-v2ray>
- <https://github.com/mwarning/openwrt-examples>
- <https://github.com/pexcn/openwrt-chinadns-ng>
- <https://github.com/project-openwrt/luci-app-vssr-1>
- <https://github.com/pymumu/luci-app-smartdns>
- <https://github.com/shadowsocks/luci-app-shadowsocks>
- <https://github.com/shadowsocks/openwrt-shadowsocks>
- <https://github.com/xiaorouji/openwrt-passwall>: contain passwall
- <https://github.com/fw876/helloworld>: official luci-app-ssr-plus

### Pakcage collects

- <https://github.com/project-openwrt>: all valued packages
- <https://github.com/kenzok8/openwrt-packages>
- <https://github.com/liuran001/openwrt-packages>: archived

The modified `ssr-plus` also need many dependencies. The good news is it can be built seperately.

## Reference

- builfd SSR-Plus
  - <https://www.qiqisvm.life/archives/102>
  - <https://www.solarck.com/install-ssr-plus.html>
- Lean's pakcage description
  - <https://www.right.com.cn/forum/thread-344825-1-1.html>
  - <https://www.right.com.cn/forum/thread-1237348-1-1.html>
- <https://openwrt.org/docs/guide-developer/single.package>
- <https://jarviswwong.com/compile-ipk-separately-with-openwrt.html>, solve `staging_dir/host/bin/upx: No such file or directory`
