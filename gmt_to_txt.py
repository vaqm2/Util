#!/usr/bin/env python

import sys

gmt = open(sys.argv[1], 'r')

for set in gmt:
    set_contents = set.rstrip().split()
    set_name = set_contents[0]
    for gene in set_contents[2:]:
        print(f'{set_name}\t{gene}')
gmt.close()