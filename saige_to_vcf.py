#!/usr/bin/env python

import sys
import argparse
from cyvcf2 import VCF, Writer, Variant

def main():
    parser = argparse.ArgumentParser(description = "Convert SAIGE association output to gzip'ped VCF")
    parser.add_argument('--assoc', type = str, help = "SAIGE Association Output", required = True)
    parser.add_argument('--template', type = str, help = "VCF template", required = True)
    parser.add_argument('--out', type = str, help = "Output VCF prefix", required = True)
    args = parser.parse_args()

    try:
        fr = open(args.assoc, "r")
    except:
        print("ERROR: When opening SAIGE association file: ", sys.exc_info()[0], "has occurred!")

    try:
        out_vcf = args.out + ".vcf.gz"
        fw = open(out_vcf, args.template, "wz")
        fw.samples[0] = args.out
    except:
        print("ERROR: When creating output VCF: ", sys.exc_info()[0], "has occurred!")

    for line in fr:
        if line.startswith("CHR"):
            continue
        else:
            assoc_contents       = line.split()
            variant              = Variant()
            variant.CHROM        = assoc_contents[0]
            variant.start        = assoc_contents[1]
            variant.end          = assoc_contents[1]
            variant.ID           = assoc_contents[2]
            variant.REF          = assoc_contents[3]
            variant.ALT          = assoc_contents[4]
            variant.QUAL         = "100"
            variant.FILTER       = "PASS"
            variant.format['AF'] = assoc_contents[6]
            variant.INFO['DR2']  = assoc_contents[7]
            variant.format['SS'] = assoc_contents[8]
            variant.format['ES'] = assoc_contents[9]
            variant.format['SE'] = assoc_contents[10]
            variant.format['LP'] = -1 * log10(assoc_contents[12])
            fw.write_record(variant)

    fr.close()
    fw.close()

if __name__ == '__main__':
    main()