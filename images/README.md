# Build K2P

Please use [PandoraBox](https://downloads.pangubox.com/pandorabox/19.01/targets/ralink/mt7621/PandoraBox-ralink-mt7621-k2p-2019-01-01-git-3e8866933-squashfs-sysupgrade.bin) or [mleaf CC build](http://www.mleaf.org/downloads/K2P-Chaos_Calmer/v1.7.2/cc-k2p-v1.7.2-16m.bin).

According to <https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=a4c84b2d734f0cba40b3d0a2183dbf221e7356e5>, Wireless radio doesn't work due to the lack of driver.
Another important is the firmware start `0xa0000`, <https://git.openwrt.org/?p=openwrt/openwrt.git;a=blob;f=target/linux/ramips/dts/K2P.dts;h=4089ce64f5da120bb4d1ac884be4168ea637f546;hb=a4c84b2d734f0cba40b3d0a2183dbf221e7356e5>

## Preparation

`apt install -y ocaml-nox help2man texinfo yui-compressor`
