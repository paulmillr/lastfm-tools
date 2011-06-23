#!/usr/bin/env python
"""
This module is used when lastfmtools is run
as a standalone application.
"""
__doc__ = """Usage: {} mode, field, filename, [username, password]""".format(
    __file__)

import sys
from optparse import OptionParser
from .lastfm import Lastfm


def main():
    parser = OptionParser(prog='lastfmtools')
    parser.add_option('-v', '--verbose',
                      action='store_true', dest='verbose', default=False,
                      help='be verbose')
    (options, args) = parser.parse_args()

    def warn():
        print(__doc__)
        raise TypeError('Invalid mode')
    arg = sys.argv[1:]
    mode = arg.pop(0) if len(arg) else None
    if not len(arg) or mode not in ['dump', 'scrobble', 'sync']:
        warn()
    if mode == 'sync':
        if len(arg) != 2:
            warn()
        field, filename = arg
        lastfm = Lastfm()
        lastfm.sync(field, filename)
    else:
        if len(arg) != 4:
            warn()
        field, filename, username, password = arg
        lastfm = Lastfm(username, password)
        getattr(lastfm, mode)(field, filename)

    return 0

if __name__ == '__main__':
    sys.exit(main())
