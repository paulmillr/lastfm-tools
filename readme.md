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
    python lastfm.py backup played_count backup_file_location username password

    # This would sync lastfm data with an iTunes (on macs).
    python lastfm.py sync played_count backup_file_location
    python lastfm.py sync rating backup_file_location

    # This would upload data from a single file to last.fm account.
    python lastfm.py restore backup_file_location username password
