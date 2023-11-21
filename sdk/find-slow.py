#!/usr/bin/env python3

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

import logging
import os


def main(filename: str, threshold: int):
    mm = {}
    with open(filename) as fp:
        for line in fp:
            ll = line.strip().split(" ")
            if int(ll[2]) > threshold:
                mm[ll[6]] = ll[2]
    for item in sorted(mm.keys()):
        print(f"{item} => {mm[item]}")

if __name__ == "__main__":
    parser = ArgumentParser(description="Convert pcap file to json files", formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument("-i", "--input", required=True, help="The path for pcap file")
    parser.add_argument("-t", "--threshold", type=int, default=300, help="The path for pcap file")
    parser.add_argument("-v", "--verbose", action="store_true", default=False, help="Print command or console prompt")

    args = parser.parse_args()
    log_format = "%(levelname)-8s [%(filename)s:%(lineno)d] %(message)s"
    if args.verbose:
        logging.basicConfig(format=log_format, level="INFO")
    else:
        logging.basicConfig(format=log_format, level=os.environ.get("LOGLEVEL", "WARNING").upper())
    if os.path.exists(args.input) and os.path.isfile(args.input):
        main(args.input, args.threshold)
    else:
        logging.error("Error: %s", args.input)
