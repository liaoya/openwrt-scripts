#!/bin/bash

git clone https://github.com/shadowsocks/openwrt-feeds.git package/feeds
git clone https://github.com/shadowsocks/openwrt-shadowsocks.git package/shadowsocks-libev
git clone https://github.com/shadowsocks/luci-app-shadowsocks.git package/luci-app-shadowsocks
pushd package/luci-app-shadowsocks/tools/po2lmo || exit
make && sudo make install
popd || exit

make -j4 package/shadowsocks-libev/compile
make -j4 package/luci-app-shadowsocks/compile
