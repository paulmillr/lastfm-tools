#!/usr/bin/env python
# encoding: utf-8
import socket
import unittest
import urllib.request
import urllib.error
import urllib.parse
import time
from collections import OrderedDict
from urllib.parse import urlencode
from lxml.etree import XML


class API:
    def __init__(self, user="", limit=150,
                 api_key="b25b959554ed76058ac220b7b2e0a026"):
        self.user = user
        self.key = api_key
        self.limit = limit
        self.opener = urllib.request.build_opener()
        self.cache = {}

    def _get_url(self, **kwargs):
        kwargs.update({
            "user": self.user,
            "api_key": self.key,
            "limit": self.limit,
        })

        return "http://ws.audioscrobbler.com/2.0/?{}".format(
            urlencode(kwargs))

    def _convert(self, xml_page):
        xml_page = xml_page[0]
        a = xml_page.attrib
        stat = {
            "tracks": int(a["total"]),
            "limit": int(a["perPage"]),
            "pages": int(a["totalPages"]),
        }
        # We use OrderedDict here because we need to write data to file
        # only in that order.
        songs = []
        for song in xml_page:
            art = song.find("artist")
            name = art.find("name")
            art = name.text if name is not None else art.text
            ts = song.find("date")
            if ts is not None:
                ts = int(ts.attrib["uts"])
            data = OrderedDict((
                ("artist", art),
                ("title", song.find("name").text),
                ("timestamp", ts),
            ))
            songs.append(data)
        return {"stat": stat, "songs": songs}

    def _get(self, **kwargs):
        url = self._get_url(**kwargs)
        #print(url)  # for debugging
        try:
            data = self.opener.open(url, timeout=20)
            xml_page = XML(data.read())
            return self._convert(xml_page)
        except (urllib.error.URLError, socket.timeout) as e:
            print(("\nGot error {}, reconnecting. "
                   "Last page: {}".format(e, url)))
            time.sleep(10)
            return self._get(**kwargs)

    def get(self, method, page=1):
        """Page -- usually instance of slice()."""
        total = self.total(method)["pages"]
        if isinstance(page, slice):
            start, stop, step = (page.start or 1, page.stop or total,
                                 page.step or 1)
            if start < 0:
                start = total + start + 1
            if stop < 0:
                stop = total + stop + 1
            if start == stop:
                stop += 1
            for page in range(start, stop, step):
                yield self._get(method=method, page=page)
        else:
            if page < 1:
                page = total + page + 1
            yield self._get(method=method, page=page)

    def total(self, method):
        return self.cache.setdefault(method, self._get(method=method)["stat"])


class APITests(unittest.TestCase):
    def setUp(self):
        self.api = API("docbay0", limit=10)

    def test_get_url(self):
        import cgi
        s = ("http://ws.audioscrobbler.com/2.0/?user=docbay0"
            "&api_key=b25b959554ed76058ac220b7b2e0a026&limit=10"
            "&page=1&method=user.getlovedtracks")
        url = self.api._get_url(method="user.getlovedtracks", page=1)

        self.assertEqual(urllib.parse.parse_qs(s), urllib.parse.parse_qs(url))

    def test_recent_tracks(self):
        l = list(self.api.get("user.getrecenttracks", -1))
        first_song_timestamp = l.pop()["songs"][-1]["timestamp"]
        self.assertEqual(first_song_timestamp, 1258006253)

if __name__ == "__main__":
    unittest.main()
