#!/usr/bin/env python

from distutils.core import setup
import os.path

# Utility function to read the README file.
# Used for the long_description.  It"s nice, because now 1) we have a top level
# README file and 2) it"s easier to type in the README file than to put a raw
# string in below ...


def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(
    name="lastfmtools",
    version="0.0.1",
    packages=["lastfmtools"],
    package_data={
        "": ["*.txt", "*.rst", "*.md"]
    },
    data_files=[
        ("", ["LICENSE"])
    ],

    author="Paul Miller",
    author_email="paulpmiller@gmail.com",
    description="No description entered for lastfmtools",
    url="http://github.com/paulmillr/lastfmtools",
    license="MIT",

    long_description=read("readme.md"),
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "Topic :: Utilities",
        "License :: OSI Approved :: MIT License",
    ],
)
