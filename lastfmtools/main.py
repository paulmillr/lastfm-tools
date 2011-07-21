#!/usr/bin/env python
"""
This module is used when lastfmtools is run
as a standalone application.
"""

import sys
import argparse
import getpass
from .lastfm import Lastfm


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", dest="mode", required=True,
                        choices=["dump", "scrobble", "sync"])
    parser.add_argument("--field", dest="field", required=True,
                        choices=["played_count", "rating"],
                        help="Field, that application would dump / sync. ")
    parser.add_argument("--file", dest="filename", required=True,
                        help="Path to file, that application would work with.")
    parser.add_argument("--username", dest="username")
    args = parser.parse_args()
    mode, field, filename = args.mode, args.field, args.filename

    arguments = {}
    if mode in ["dump", "scrobble"]:
        uname = args.username
        if uname is None:
            print("You need to enter lastfm username in this mode.\n")
            parser.print_usage()
            return 0
        arguments["username"] = uname
    if mode == "scrobble":
        arguments["password"] = getpass.getpass(
            "Please, enter your lastfm password: "
        )
    lastfm = Lastfm(**arguments)
    getattr(lastfm, mode)(field, filename)

    return 0

if __name__ == "__main__":
    sys.exit(main())
