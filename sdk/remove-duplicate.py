#!/usr/bin/env python3
# We will not use it now.

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from pathlib import Path, PurePath

import logging
import os
import sys


def in_official(path: PurePath):
    for official in ("base", "packages", "luci", "routing", "telephony"):
        official = PurePath("feeds").joinpath(official)
        if path.is_relative_to(official):
            return True
    return False


def main(feeds_dir: Path, dryrun: bool = True):
    mm = {}
    for p in feeds_dir.glob('*.index'):
        with p.open() as fp:
            name = None
            path = None
            for line in fp:
                if line.find("Package:") < 0 and line.find("Source-Makefile:") < 0:
                    continue
                idx = line.find("Source-Makefile:")
                if idx == 0:
                    name = None
                    path = PurePath(line[len("Source-Makefile:"):].strip()).parent
                idx = line.find("Package:")
                if idx == 0:
                    name = line[len("Package:"):].strip()
                if name and path:
                    if name in mm and in_official(mm[name]) and not in_official(path):
                        fullpath = Path(feeds_dir).parent / mm[name]
                        if fullpath.exists():
                            if dryrun:
                                print(fullpath)
                            else:
                                fullpath.rmdir()
                    mm[name] = path


if __name__ == "__main__":
    parser = ArgumentParser(description="Convert pcap file to json files", formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument("-f", "--feeds", default=True, help="keep one copy message only")
    parser.add_argument("-d", "--dryrun", action="store_true", default=False, help="keep one copy message only")
    parser.add_argument("-v", "--verbose", action="store_true", default=False, help="Print command or console prompt")

    args = parser.parse_args()
    log_format = "%(levelname)-8s [%(filename)s:%(lineno)d] %(message)s"
    if args.verbose:
        logging.basicConfig(format=log_format, level="INFO")
    else:
        logging.basicConfig(format=log_format, level=os.environ.get("LOGLEVEL", "WARNING").upper())

    feeds_dir = Path(args.feeds)
    if not feeds_dir.exists() or not feeds_dir.is_dir():
        logging.error("%s is illegal", args.feeds)
        sys.exit(1)
    main(feeds_dir, args.dryrun)
    # main(Path("/work/github/liaoya/openwrt-scripts/sdk/host/immortalwrt-sdk-21.02.7-armvirt-64_gcc-8.4.0_musl.Linux-x86_64/feeds"))
