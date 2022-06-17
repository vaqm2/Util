#!/usr/bin/env python

import sys
import argparse
from datetime import date
from math import log10

def main():
    parser = argparse.ArgumentParser(description = "Convert SAIGE association output to gzip'ped VCF")
    parser.add_argument('--assoc', type = str, help = "SAIGE Association Output", required = True)
    parser.add_argument('--out', type = str, help = "Output VCF prefix", required = True)
    args = parser.parse_args()

    try:
        fr = open(args.assoc, "r")
    except:
        print("ERROR: When opening SAIGE association file: ", sys.exc_info()[0], "has occurred!")

    try:
        out_vcf = args.out + ".vcf.gz"
        fw = open(out_vcf, "wz")
    except:
        print("ERROR: When creating output VCF: ", sys.exc_info()[0], "has occurred!")

    for line in fr:
        if line.startswith("CHR"):
            print("##fileformat=VCFv4.3\n")
            print("##fileDate=" + date.today.strftime("%y%m%d") + "\n")
            print("##source=saige_to_vcf.py\n")
            print("##FORMAT=<ID=ES>,Number=A,Type=FLOAT,Description=\"Effect Size of ALT\"\n")
            print("##FORMAT=<ID=ES>,Number=A,Type=FLOAT,Description=\"Standard Error of Effect Size\"\n")
            print("##FORMAT=<ID=LP>,Number=A,Type=FLOAT,Description=\"Negative log of P-value for Effect Size\"\n")
            print("##FORMAT=<ID=AFKG>,Number=A,Type=FLOAT,Description=\"Frequency of ALT\"\n")
            print("##FORMAT=<ID=DR2>,Number=A,Type=FLOAT,Description=\"Imputation INFO score\"\n")
            print("##FORMAT=<ID=SS>,Number=A,Type=FLOAT,Description=\"Sample Size\"\n")
            print("#CHR\tBP\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t")
            print(args.out + "\n")
        else:
            assoc_contents       = line.split()
            chromosome           = assoc_contents[0]
            position             = assoc_contents[1]
            snp                  = assoc_contents[2]
            ref_allele           = assoc_contents[3]
            alt_allele           = assoc_contents[4]
            qual                 = "100"
            filter               = "PASS"
            alt_allele_frequency = assoc_contents[6]
            imputation_info      = assoc_contents[7]
            sample_size          = assoc_contents[8]
            effect_size          = assoc_contents[9]
            standard_error       = assoc_contents[10]
            negative_logp        = -1 * log10(assoc_contents[12])

            print(chromosome + "\t")
            print(position + "\t")
            print(snp + "\t")
            print(ref_allele + "\t")
            print(alt_allele + "\t")
            print(qual + "\t")
            print(filter + "\t")
            print("." + "\t")
            print("ES:SE:EP:AFKG"+ "\t")
            print(effect_size + ":")
            print(standard_error + ":")
            print(negative_logp + ":")
            print(alt_allele_frequency + ":")
            print(imputation_info + "\n")

    fr.close()
    fw.close()

if __name__ == '__main__':
    main()