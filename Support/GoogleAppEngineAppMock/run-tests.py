#!/usr/bin/env python

import optparse
import sys
import os.path

import unittest
import unittest.loader

USAGE = """%prog TEST_PATH
Run unit tests for App Engine apps.

TEST_PATH   Path to package containing test modules"""


def main(test_path):
    if os.path.exists(test_path):
        unittest.TextTestRunner(verbosity=2).run(unittest.loader.TestLoader().discover(test_path))
    else:
        unittest.TextTestRunner(verbosity=2).run(unittest.loader.TestLoader().loadTestsFromName(test_path))

if __name__ == '__main__':
    parser = optparse.OptionParser(USAGE)
    options, args = parser.parse_args()
    if len(args) != 1:
        print 'Error: Exactly 1 argument required.'
        parser.print_help()
        sys.exit(1)
    TEST_PATH = args[0]
    main(TEST_PATH)
