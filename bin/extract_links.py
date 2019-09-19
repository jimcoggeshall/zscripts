#!/usr/bin/env python

from __future__ import print_function

import sys
import json
import tldextract
from bs4 import BeautifulSoup

def main():
    for line in sys.stdin:
        parsed = json.loads(line.rstrip())
        addr = parsed.get("ip")
        ts = parsed.get("timestamp")
        html = parsed.get("data", {}).get("http", {}).get("response", {}).get("body", "")
        soup = BeautifulSoup(html, 'html.parser')
        for link in soup.find_all('a'):
            target = link.get("href", "")
            target_extr = tldextract.extract(target)
            if len(target_extr.suffix) > 0 and len(target_extr.domain) > 0:
                target_domain = ".".join([target_extr.subdomain, target_extr.domain, target_extr.suffix]).lstrip(".").rstrip(".")
                print(ts, addr, target_domain)
    return

if __name__ == "__main__":
    main()
