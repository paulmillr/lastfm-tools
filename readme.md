# Lastfmtools
Script for last.fm backuping and restoring. Requires Python 3.2.

## What?
This script allows you to:

* Backup whole listening statistics of lastfm user to a file.
* Sync lastfm's song play count & rating with iTunes.
* Restore listening statistics to another lastfm account.

## Use cases

* Keep lastfm synced with your itunes.
* Change nickname on the lastfm (backup statistics to the file,
restore on new account).
* Cheat on the lastfm.

## License
Created by Paul Miller. Distributed under [MIT License](http://creativecommons.org/licenses/MIT/).
Some parts of code are taken from Ionut Bizau's script (BSD license).

## Dependencies
* [lxml](http://codespeak.net/lxml/)
* [appscript](http://appscript.sourceforge.net/py-appscript/index.html)

## Usage
    # This would download all last.fm data to a single file.
    ./run --mode=backup --field=played_count --file=filename --username=username

    # This would sync lastfm data with an iTunes (on macs).
    ./run --mode=sync --field=played_count --file=filename
    ./run --mode=sync --field=rating --file=filename

    # This would upload data from a single file to last.fm account.
    ./run --mode=restore --field=played_count --file=filename --username=username
