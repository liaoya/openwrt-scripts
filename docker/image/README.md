# README

User OpenWRT docker image to build firmware

There're no image after `18.06.7` for `18.06` series

- `docker.io/openwrtorg/imagebuilder:x86-64-21.02.3`
- `docker.io/openwrtorg/imagebuilder:ramips-mt7621-21.02.3`
- `docker.io/openwrtorg/imagebuilder:x86-64-19.07.8`
- `docker.io/openwrtorg/imagebuilder:x86-64-18.06.7`

The command to build

```bash
PACKAGES="${PACKAGES:+$PACKAGES }-wpad-mini -wpad-basic -dnsmasq"
PACKAGES="${PACKAGES:+$PACKAGES }bash bind-dig coreutils-base64 curl diffutils dnsmasq-full dropbearconvert fdisk file \
ip-full ipset \
lscpu \
luci luci-theme-bootstrap \
nano pciutils procps-ng-pkill tcpdump tmux \
uci wget wpad"
export PACKAGES

# Use cache server
export http_proxy=http://10.245.91.190:3128
export https_proxy=http://10.245.91.190:3128
export no_proxy=localhost,127.0.0.1,calix.local,calix.dev

bash build.sh -b bin-18.06.7 -v 18.06.7

# if OpenWrt above 18.06
export PACKAGES=${PACKAGES:+$PACKAGES }atop
bash build.sh -b bin-19.07.8 -v 19.07.8
bash build.sh -b bin-21.02.3 -v 21.02.3

env CONFIG_TARGET_KERNEL_PARTSIZE=16 CONFIG_TARGET_ROOTFS_PARTSIZE=128 ./build.sh -b bin-19.07.8 -v 19.07.8
```
