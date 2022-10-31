#!/usr/bin/env python

import sys
from cyvcf2 import VCF
from os import path
from datetime import datetime

vcf_file = VCF(sys.argv[1])

variants_read = 0

for variant in vcf_file:
    variants_read += 1

    if(variants_read % 1000 == 1):
        print("INFO: ", variants_read, " at", datetime.now())