#!/usr/bin/env python
# encoding: utf-8
import sys
import appscript
import urllib.request
import urllib.error
import urllib.parse
from io import StringIO
from hashlib import md5
from gzip import GzipFile
from operator import itemgetter
from time import time
from .API import API


def print_flush(text):
    sys.stdout.write("\r" + text)
    sys.stdout.flush()


class Lastfm:
    """Methods for working with last.fm tracks."""
    SEPARATOR = "\t"
    MAX_TITLE_LENGTH = 150  # lastfm trims track title
    TRACK_TEMPLATE = """ <item>
      <artist>{artist}</artist>
      <album></album>
      <track>{title}</track>
      <duration></duration>
      <timestamp>{timestamp!s}</timestamp>
      <playcount>{playcount}</playcount>
      <filename></filename>
      <uniqueID></uniqueID>
      <source>2</source>
      <authorisationKey></authorisationKey>
      <userActionFlags>0</userActionFlags>
      <path></path>
      <fpId></fpId>
      <mbId></mbId>
      <playerId></playerId>
      <mediaDeviceId></mediaDeviceId>
     </item>
    """
    methods_map = {
        "played_count": "user.getrecenttracks",
        "rating": "user.getlovedtracks",
    }
    fields = ("artist", "title", "timestamp")

    def __init__(self, username="", password=""):
        self.username = username
        self.password = password
        self.api = API(username)

    def _write(self, file, song):
        try:
            line = self.SEPARATOR.join(str(i) for i in song.values()) + "\n"
            file.write(line)
        except AttributeError:
            pass

    def _split_line(self, line, utf8=True):
        if utf8:
            line = line.decode("utf-8")
        track = line.strip().split(self.SEPARATOR)
        track[2] = int(track[2])  # timestamp
        return dict(list(zip(self.fields, track)))

    def _parse_logfile_itunes(self, f):
        return [self._split_line(line) for line in f]

    def _parse_logfile_lastfm(self, f):
        return [self._split_line(line, False) for line in f]

    def bootstrap(self, tracks):
        timestamp = str(int(time()))
        hd = md5(self.password).hexdigest()
        auth = md5(hd + timestamp).hexdigest()
        authlower = md5(hd.lower() + timestamp).hexdigest().lower()
        buff = StringIO()
        buff.write("content-disposition: form-data; name=\"agency\"\r\n")
        buff.write("\r\n")
        buff.write("0\r\n")
        buff.write("--AaB03x\r\n")
        buff.write("content-disposition: form-data; name=\"bootstrap\"; "
            "filename=\"iTunes_bootstrap.xml.gz\"\r\n")
        buff.write("Content-Transfer-Encoding: binary\r\n")
        buff.write("\r\n")
        zipped = GzipFile("iTunes_bootstrap.xml", "w", 6, buff)
        zipped.write("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
        zipped.write("<bootstrap version=\"1.0\" product=\"iTunes\">\n")
        for track in tracks:
            zipped.write(self.TRACK_TEMPLATE.format(**track))
        zipped.write("</bootstrap>\n")
        zipped.close()
        buff.write("\r\n")
        buff.write("--AaB03x--")
        buff.seek(0)
        url_template = ("http://bootstrap.last.fm/bootstrap/index.php?"
                        "user={username}&time={timestamp}&auth={auth}"
                        "&authlower={authlower}")
        url = url_template.format(username=self.username,
            timestamp=timestamp, auth=auth, authlower=authlower)
        headers = {"Content-type": "multipart/form-data, boundary=AaB03x",
                   "Cache-Control": "no-cache", "Accept": "*/*"}
        # print(url)
        urllib.request.urlopen(
            urllib.request.Request(url, buff.read(), headers)
        )

    def _prepare_tracks(self, tracks):
        def iterate(grouped):
            for artist_tracks in grouped.values():
                for track in artist_tracks.values():
                    yield track
        grouped = self._group_tracks(tracks)
        return sorted(iterate(grouped), key=itemgetter("timestamp"))

    def _clean_track(self, track, is_itunes=False):
        if is_itunes:
            artist, title = (track.artist.get(),
                             track.name.get())
        else:
            artist, title = track["artist"], track["title"]
        artist = artist.lower()
        title = title.lower()[:self.MAX_TITLE_LENGTH]
        if is_itunes:
            return (artist, title)
        else:
            track["artist"], track["title"] = artist, title
            return track

    def _group_tracks(self, tracks):
        grouped = {}
        for track in tracks:
            track["played_count"] = 0
            track = self._clean_track(track)
            artist, title = track["artist"], track["title"]
            artist_tracks = grouped.setdefault(artist, {})
            artist_tracks.setdefault(title, track)
            artist_tracks[title]["played_count"] += 1
        return grouped

    def _set_itunes(self, field, tracks):
        itunes_tracks = appscript.app("iTunes").tracks.get()
        for track in itunes_tracks:
            artist, title = self._clean_track(track, True)
            try:
                song = tracks[artist][title]
            except KeyError:
                continue
            value = 100 if field == "rating" else song[field]
            getattr(track, field).set(value)
            print("Track {} - {}, setting {} to {}.".format(
                artist, title, field, value
            ))

    def dump(self, field, filename, start=1, stop=None, step=1):
        """Backups user tracks to file."""
        method = self.methods_map[field]
        t = self.api.total(method)
        tracks, limit, pages = t["tracks"], t["limit"], t["pages"]
        total = stop * (limit / step) if stop else tracks
        with open(filename, "w") as f:
            print("Method is", method)
            pages = self.api.get(method, slice(start, stop, step))
            for n, page in enumerate(pages, start=1):
                cur = start + (limit / step) * n
                print_flush("{} tracks dumped from {}".format(abs(cur), total))
                for song in page["songs"]:
                    self._write(f, song)
            print()

    def scrobble(self, filename):
        """Scrobbles songs from file."""
        with open(filename, "r") as f:
            tracks = self._prepare_tracks(self._parse_logfile_lastfm(f))
        self.bootstrap(tracks)

    def sync(self, field, filename):
        with open(filename, "r") as f:
            tracks = self._group_tracks(self._parse_logfile_itunes(f))
        self._set_itunes(field, tracks)
