#!/bin/bash

set -ex

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

function build() {
    for src_dir in package/feeds/Lienol package/feeds/liuran001 package/feeds/xiaorouji; do
        for pkg in "${src_dir}"/*; do
            [[ -d ${pkg} ]] || continue
            make -j"$(nproc)" "${pkg}"/compile || true
        done
    done
}

bash "${THIS_DIR}"/setup.sh -d ~/Downloads/dl -n /work/armvirt -t armvirt -c
(cd /work/armvirt; build)
bash "${THIS_DIR}"/setup.sh -t ~/Downloads/dl -n /work/x64 -t x64 -c
(cd /work/x64; build)
bash "${THIS_DIR}"/setup.sh -d ~/Downloads/dl -n /work/mt7621 -t mt7621 -c
(cd /work/mt7621; build)
bash "${THIS_DIR}"/setup.sh -d ~/Downloads/dl -n /work/mt7620 -t mt7620 -c
(cd /work/mt7620; build)
bash "${THIS_DIR}"/setup.sh -d ~/Downloads/dl -n /work/ar71xx -t ar71xx -c
(cd /work/ar71xx; build)