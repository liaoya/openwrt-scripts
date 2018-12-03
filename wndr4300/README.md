# Build OpenWRT firmware for netgear wndr4300v1

The build script is mainly based on the method of <https://gist.github.com/travislee8964/91f92d4faa3e9b53ecae147678fd0385>.

This build script can 

* build lede 17.01 or openwrt 18.06
* Enable zh-cn of i18
* Add <http://openwrt-dist.sourceforge.net/packages> for the best shadowsocks solution I found for openwrt.

## Build on Ubuntu

- Run `apt-get install subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc wget unzip python time`
- Run `bash build -v 17.01.6`
- Run `bash build -v 18.06.1`
