# OpenWrt sdk docker image

- <https://github.com/topics/openwrt-feed>

```bash
docker run --rm -it -u $(id -u):$(id -g) -v $PWD/bin:/builder/bin -v /work/openwrt/dl:/builder/dl docker.io/openwrt/sdk:x86-64-23.05.2 bash

export GIT_PROXY=http://192.168.1.202:9080/
git config --global url."${GIT_PROXY}".insteadOf https://
sed -e 's|git.openwrt.org/openwrt/openwrt|github.com/openwrt/openwrt|g' \
    -e 's|git.openwrt.org/feed/packages|github.com/openwrt/packages|g' \
    -e 's|git.openwrt.org/project/luci|github.com/openwrt/luci|g' \
    -e 's|git.openwrt.org/feed/telephony|github.com/openwrt/telephony|g' \
    -e '\%^src-git packages https://github.com/openwrt/packages% s%.%#&%' \
    -e '\%^src-git-full packages https://github.com/openwrt/packages% s%.%#&%' \
    -i feeds.conf.default

scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a
rm -fr .config ./tmp
make defconfig

echo "src-git jell https://github.com/kenzok8/jell" >>feeds.conf.default

make -j package/feeds/luci/luci-base/compile
```

- `docker.io/openwrt/sdk:x86-64-23.05.2`
- `docker.io/openwrt/sdk:x86-64-22.03.6`
- `docker.io/openwrt/sdk:x86-64-21.02.7`
- `docker.io/openwrt/sdk:x86-64-19.07.10`
- `docker.io/openwrt/sdk:x86-64-18.06.7`

- `docker.io/openwrt/sdk:armsr-armv8-23.05.2`
- `docker.io/openwrt/sdk:armvirt-64-22.03.6`
- `docker.io/openwrt/sdk:armvirt-64-21.02.7`

- `docker.io/openwrt/sdk:ath79-nand-23.05.2`
- `docker.io/openwrt/sdk:ath79-nand-22.03.6`
- `docker.io/openwrt/sdk:ath79-nand-21.02.7`

- `docker.io/openwrt/sdk:ramips-mt7621-23.05.2`
- `docker.io/openwrt/sdk:ramips-mt7621-22.03.6`
- `docker.io/openwrt/sdk:ramips-mt7621-21.02.7`

- `docker.io/immortalwrt/sdk:armsr-armv8-openwrt-23.05.1`
- `docker.io/immortalwrt/sdk:ath79-nand-openwrt-23.05.1`
- `docker.io/immortalwrt/sdk:ramips-mt7621-openwrt-23.05.1`
- `docker.io/immortalwrt/sdk:x86-64-openwrt-23.05.1`

- `docker.io/immortalwrt/sdk:armvirt-64-openwrt-21.02.7`
- `docker.io/immortalwrt/sdk:ath79-nand-openwrt-21.02.7`
- `docker.io/immortalwrt/sdk:ramips-mt7621-openwrt-21.02.7`
- `docker.io/immortalwrt/sdk:x86-64-openwrt-21.02.7`

```bash
# export GIT_PROXY=http://192.168.1.202:9080/
export GIT_PROXY=http://10.245.91.190:9080/

for target in ath79-nand armsr-armv8 ramips-mt7621 x86-64; do
    # bash -x run.sh -t "${target}" "src-git jell https://github.com/kenzok8/jell;main"
    bash -x run.sh -t "${target}" "src-git kenzok8 https://github.com/kenzok8/openwrt-packages" "src-git small https://github.com/kenzok8/small"
    # bash -x run.sh -t "${target}" "src-git oaf https://github.com/destan19/OpenAppFilter"
done

for target in ath79-nand armvirt-64 ramips-mt7621 x86-64; do
    # bash -x run.sh -t "${target}" -v 21.02.7 "src-git jell https://github.com/kenzok8/jell;main"
    bash -x run.sh -t "${target}" -v 21.02.7 "src-git kenzok8 https://github.com/kenzok8/openwrt-packages"
    # bash -x run.sh -t "${target}" -v 21.02.7 "src-git small https://github.com/kenzok8/small" "src-git oaf https://github.com/destan19/OpenAppFilter"
done

for target in ath79-nand armsr-armv8 ramips-mt7621 x86-64; do
    # bash -x run.sh -d ImmortalWrt -v 23.05.1 -t "${target}" "src-git jell https://github.com/kenzok8/jell;main"
    bash -x run.sh -d ImmortalWrt -v 23.05.1 -t "${target}" "src-git kenzok8 https://github.com/kenzok8/openwrt-packages" "src-git small https://github.com/kenzok8/small"
    # bash -x run.sh -d ImmortalWrt -v 23.05.1 -t "${target}" "src-git oaf https://github.com/destan19/OpenAppFilter"
done

for target in ath79-nand armvirt-64 ramips-mt7621 x86-64; do
    # bash -x run.sh -d ImmortalWrt -v 21.02.7 -t "${target}" "src-git jell https://github.com/kenzok8/jell;main"
    bash -x run.sh -d ImmortalWrt -v 21.02.7 -t "${target}" "src-git kenzok8 https://github.com/kenzok8/openwrt-packages" "src-git small https://github.com/kenzok8/small"
    # bash -x run.sh -d ImmortalWrt -v 21.02.7 -t "${target}" "src-git oaf https://github.com/destan19/OpenAppFilter"
done
```

Clean the images

```bash
docker image ls --format "{{.ID}} {{.Repository}}:{{.Tag}}" | grep -E 'openwrt|immortalwrt' | cut -d" " -f1 | xargs docker image rm
```
