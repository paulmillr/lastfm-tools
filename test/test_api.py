#!/usr/bin/env python

import unittest


class SanityTest(unittest.TestCase):
    def runTest(self):
        self.assertTrue(2 * 2 == 4)

if __name__ == "__main__":
    unittest.main()
