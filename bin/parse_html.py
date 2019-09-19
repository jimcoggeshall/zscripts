#!/usr/bin/env python

from __future__ import print_function

import sys
from bs4 import BeautifulSoup

def main():
    for line in sys.stdin:
        soup = BeautifulSoup(line, 'html.parser')
        print(soup.prettify())
#        for anchor in soup.find_all('a'):
#            print(anchor.get('href', '/'))
    return

if __name__ == "__main__":
    main()
