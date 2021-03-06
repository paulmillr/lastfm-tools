# Last.FM Tools
Last.FM backuper, helper and data analyzer.

I'm using [last.fm](http://last.fm) to track statistics of
music i've listened to. Basically I tag all artists of which i've listened five
and more tracks with tags `good`, `meh` and `shit`.

This software greatly facilitates statistics parsing, syncing and sharing great artists with friends.

## Installation
`gem install lastfm_tools` if you're using ruby 1.9.3 (other versions untested).

## Command line API
Command line API is very simple and speaks english. Also, it'll search for
`.lastfm_tools` file in your user directory and create it if it doesn't exist.

Usage is: `lastfmtools "query"`. Example queries:

* `sync` will sync tags user and tracks to local files in
order to not mess around Last.FM API limits in the future. Backup format
is JSON.
* `sync with itunes` will adjust tracks listen count in iTunes and
it will be equal to tracks listen count on last.fm.
* `show best hip-hop artists` will print a list of 7 hip-hop
artists i've listened to and which I tagged with tags `awesome` and `good`.
* `show witch house artists I hadn't listened to` will print a
list of [tag's top artists](http://www.last.fm/tag/witch%20house/artists)
that are not persist in my library yet.
* `is eminem awesome?` will print `yep` or
`nope`, depending on tag used for `eminem` in tag library. Also works for
`good`, `meh` and `shit`.
* `what is eminem?` will print `eminem is awesome / good / meh / shit`.

## `~/.lastfm_tools`
`.lastfm_tools` is an application YAML configuration file. Params it can
contain:

* :api_key - Last.FM API key, can be received here http://www.last.fm/api/account.
* :api_secret - Last.FM API secret.
* :backup_location - location to directory which will contain all your synced
data.
* :user -- your Last.FM username.

Example:

```
:api_key: '18882c02ea1e4ef8c8f1ecd68076b423'
:api_secret: 'fafc664d6c2cf58f1453f6fba4d18d38'
:backup_location: '/Users/paul/Documents/lastfm-backups/'
:user: 'docbay0'
```

## Contributing
* Clone lastfm_tools repo from github.
* Change the code.
* Install it via `rake install`.
* Run tests: `rake spec`.
* Make pull request if you want.

## License
Copyright (c) Paul Miller (http://paulmillr.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
