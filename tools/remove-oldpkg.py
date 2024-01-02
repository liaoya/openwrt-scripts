#!/usr/bin/env python3

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from pathlib import Path

import logging
import os


def remove_oldpkg(root: str):
    mm = {}
    path = Path(root) / "Packages"
    name, filename, sourcedateepoch = None, None, None
    count = 0
    with path.open() as f:
        for line in f:
            if line.find("Package:") == 0:
                name = line[len("Package:")+1:].strip()
                filename = None
                sourcedateepoch = None
            if line.find("Filename:") == 0:
                filename = line[len("Filename:")+1:].strip()
            if line.find("SourceDateEpoch:") == 0:
                sourcedateepoch = line[len("SourceDateEpoch:")+1:].strip()
            if name is not None and filename is not None and sourcedateepoch is not None:
                if name in mm:
                    if mm[name][0] < sourcedateepoch:
                        fullpath = Path(root) / mm[name][1]
                        mm[name] = (sourcedateepoch, filename)
                    else:
                        fullpath = Path(root) / filename
                    if fullpath.exists():
                        logging.info("Remove %s", fullpath)
                        fullpath.unlink()
                        count += 1
                else:
                    mm[name] = (sourcedateepoch, filename)
                name, filename, sourcedateepoch = None, None, None

    if count > 0:
        os.chdir(root)
        cmd = "ipkg-make-index.sh . > Packages && gzip -9nc Packages > Packages.gz"
        os.system(cmd)


def main(top: str):
    for root, _, _ in os.walk(top):
        path = Path(root) / "Packages"
        if path.exists() and path.is_file():
            remove_oldpkg(root)


if __name__ == "__main__":
    parser = ArgumentParser(description="Generate package index for OpenWrt", formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument("-r", "--root", required=True, help="The root directory")
    parser.add_argument("-v", "--verbose", action='count', default=0, help="more information")
    args = parser.parse_args()

    args = parser.parse_args()
    log_format = "%(levelname)-8s [%(filename)s:%(lineno)d] %(message)s"
    if args.verbose:
        logging.basicConfig(format=log_format, level="INFO")
    else:
        logging.basicConfig(format=log_format, level=os.environ.get("LOGLEVEL", "WARNING").upper())
    main(args.root)
