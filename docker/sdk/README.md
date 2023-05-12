# OpenWrt sdk docker image

```bash
docker run --rm -it -u $(id -u):$(id -g) -v $PWD/bin:/home/build/openwrt/bin docker.io/openwrt/sdk:x86-64-21.02.5 bash
```

- `docker.io/openwrt/sdk:x86-64-22.03.5`
- `docker.io/openwrt/sdk:x86-64-21.02.5`
- `docker.io/openwrt/sdk:x86-64-19.07.10`
- `docker.io/openwrt/sdk:x86-64-18.06.7`

- `docker.io/openwrt/sdk:armvirt-64-22.03.5`
- `docker.io/openwrt/sdk:armvirt-64-21.02.7`

- `docker.io/openwrt/sdk:ath79-nand-22.03.5`
- `docker.io/openwrt/sdk:ath79-nand-21.02.7`

- `docker.io/openwrt/sdk:ramips-mt7621-22.03.5`
- `docker.io/openwrt/sdk:ramips-mt7621-21.02.7`

```bash
# export GIT_PROXY=http://192.168.1.202:9080/
export GIT_PROXY=http://10.245.91.190:9080/
bash -x run.sh -p x86-64
bash -x run.sh -p armvirt-64
bash -x run.sh -p ramips-mt7621
bash -x run.sh -p ath79-nand

bash -x run.sh -p ramips-mt7620 -r
```

```bash
find package/feeds/ -iname luci-app-ssr*
make -j package/feeds/fw876/luci-app-ssr-plus/compile

make -j package/feeds/kenzok8/luci-app-bypass/compile
make -j package/feeds/kenzok8/luci-app-passwall/compile
make -j package/feeds/kenzok8/luci-app-passwall2/compile
make -j package/feeds/kenzok8/luci-app-vssr/compile

find package/feeds/ -iname "*vlmcsd*"
make -j package/feeds/jell/luci-app-vlmcsd/compile package/feeds/jell/vlmcsd/compile
```

```bash
# Setup
export GIT_PROXY=http://192.168.1.202:9080/
git config --global url."${GIT_PROXY}".insteadOf https://
sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e 's|git.openwrt.org/feed/packages|github.com/openwrt/packages|g' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -e '\%^src-git packages https://github.com/openwrt/packages% s%.%#&%' \
    -e '\%^src-git-full packages https://github.com/openwrt/packages% s%.%#&%' \
    -i feeds.conf.default
echo "src-git packages https://github.com/Lienol/openwrt-packages;22.03" >>feeds.conf.default
echo "src-git Lienol https://github.com/Lienol/openwrt-package" >>feeds.conf.default
echo "src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall" >>feeds.conf.default
echo "src-git fw876 https://github.com/fw876/helloworld" >>feeds.conf.default
echo "src-git kenzok8 https://github.com/kenzok8/openwrt-packages" >>feeds.conf.default
echo "src-git small https://github.com/kenzok8/small" >>feeds.conf.default
echo "src-git jell https://github.com/kenzok8/jell" >>feeds.conf.default
echo "src-git liuran001 https://github.com/liuran001/openwrt-packages;packages" >>feeds.conf.default

scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a
rm -fr .config ./tmp
make defconfig

make -j package/feeds/luci/luci-base/compile
```
