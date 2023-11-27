# Build OpenWrt Custom Image

OpenWrt official imagebuilder docker image for armvirt-64 miss `cpio` package

Speed the build via

- start squid cache server
- change the http proxy

```bash
export http_proxy=http://localhost:3128
export https_proxy=http://localhost:3128
```

## Setup build environment

Run the following command to install the image build requirements for Ubuntu 18.04

`sudo apt-get install -y -qq subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc wget unzip python time ocaml-nox help2man texinfo yui-compressor`

## Build

```bash
./build.sh --verbose -t armsr-armv8
```
