#!/usr/bin/env python

from __future__ import print_function

import sys
import validators
import tldextract

def validate_web_domain(domain):
    is_public_url = validators.url("http://" + domain, public=True)
    is_public_tld = len(tldextract.extract(domain).suffix) > 0
    is_valid_domain = validators.domain(domain)
    is_ipv4_address = validators.ip_address.ipv4(domain)
    is_ipv6_address = validators.ip_address.ipv6(domain)
    is_mac_address = validators.mac_address(domain)
    return is_public_url and is_public_tld and is_valid_domain and not is_ipv4_address and not is_ipv6_address and not is_mac_address

def main():
    for line in sys.stdin:
        d = str(line.rstrip())
        if validate_web_domain(d):
            print(d)
    return

if __name__ == "__main__":
    main()
