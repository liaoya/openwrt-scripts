#!/usr/bin/env python3

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from pathlib import Path

import logging
import os
import sys


def main(top: str):
    for root, dirs, _ in os.walk(top):
        if len(dirs) == 0:
            os.chdir(root)
            cmd = "ipkg-make-index.sh . > Packages && gzip -9nc Packages > Packages.gz"
            os.system(cmd)


if __name__ == "__main__":
    parser = ArgumentParser(description="Generate package index for OpenWrt", formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument("-i", "--input", required=True, help="The option file")
    parser.add_argument("-v", "--verbose", action='count', default=0, help="more information")
    args = parser.parse_args()

    args = parser.parse_args()
    log_format = "%(levelname)-8s [%(filename)s:%(lineno)d] %(message)s"
    if args.verbose:
        logging.basicConfig(format=log_format, level="INFO")
    else:
        logging.basicConfig(format=log_format, level=os.environ.get("LOGLEVEL", "WARNING").upper())
    path = Path(args.input)
    if not path.exists() or not path.is_dir():
        logging.error("%s is illegal", args.input)
        sys.exit(1)
    main(args.input)
