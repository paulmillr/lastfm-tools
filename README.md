# lastfmtools
Last.FM backuper, helper and data analyzer.

I'm using [last.fm](http://last.fm) to track statistics of
music i've listened to. Basically I tag all artists of which i've listened five
and more tracks with tags `awesome`, `good`, `meh` and `shit`.

This software greatly facilitates statistics parsing and syncing.

## Installation
`gem install lastfmtools` if you're using ruby 1.9.3 (other versions untested).

## Command line API
Command line API is very simple and speaks english. Also, it'll search for
`.lastfmtools` file in your user directory and create it if it doesn't exist.

* `lastfmtools sync` will sync tags user and tracks to local files in
order to not mess around Last.FM API limits in the future.
* `lastfmtools show best hip-hop artists` will print a list of 7 hip-hop
artists i've listened to and which I tagged with tags `awesome` and `good`.
* `lastfmtools show witch house artists I hadn't listened to` will print a
list of [tag's top artists](http://www.last.fm/tag/witch%20house/artists)
that are not persist in my library yet.
* `lastfmtools is eminem awesome?` will print `yep` or
`nope`, depended on tag used for `eminem` in tag library. Also works for
`good`, `meh` and `shit`.
* `lastfmtools what is eminem?` will print `It is awesome / good / meh / shit`.

## `~/.lastfmtools`
`.lastfmtools` is an application configuration file. Params it can contain:

* api_key - Last.FM API key, can be received here http://www.last.fm/api/account.
* api_secret - Last.FM API secret.
* backup_location - location to directory which will contain all your synced
data.

## Contributing
* Clone lastfmtools repo from github.
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