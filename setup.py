#!/usr/bin/env python

from distutils.core import setup
import os.path


def read(filename):
    with open(os.path.join(os.path.dirname(__file__), filename)) as file:
        return file.read()


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
    author_email="paulpmillr@gmail.com",
    description="No description entered for lastfmtools",
    url="http://github.com/paulmillr/lastfmtools",
    license="MIT",

    long_description=read("readme.md"),
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "Topic :: Utilities",
        "License :: OSI Approved :: MIT License",
    ],
	requires=["appscript", "lxml"],
)
