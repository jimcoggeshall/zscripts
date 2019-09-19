#!/usr/bin/env python

from __future__ import print_function

import sys
import tldextract

def main():
    for line in sys.stdin:
        host = str(line.rstrip())
        parsed_host = tldextract.extract(host)
        domain = "\t".join(
            [
                ".".join([parsed_host.subdomain, parsed_host.domain, parsed_host.suffix]), 
                ".".join([parsed_host.domain, parsed_host.suffix]), 
                parsed_host.suffix
            ]
        )
        print(domain)
    return

if __name__ == "__main__":
    main()
