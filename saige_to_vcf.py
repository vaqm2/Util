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
        out_vcf = args.out + ".vcf"
        fw = open(out_vcf, "w")
    except:
        print("ERROR: When creating output VCF: ", sys.exc_info()[0], "has occurred!")

    for line in fr:
        if line.startswith("CHR"):
            fw.write("##fileformat=VCFv4.3\n")
            fw.write("##fileDate=" + date.today().strftime("%y%m%d") + "\n")
            fw.write("##source=saige_to_vcf.py\n")
            fw.write("##FORMAT=<ID=ES>,Number=A,Type=FLOAT,Description=\"Effect Size of ALT\"\n")
            fw.write("##FORMAT=<ID=ES>,Number=A,Type=FLOAT,Description=\"Standard Error of Effect Size\"\n")
            fw.write("##FORMAT=<ID=LP>,Number=A,Type=FLOAT,Description=\"Negative log of P-value for Effect Size\"\n")
            fw.write("##FORMAT=<ID=AFKG>,Number=A,Type=FLOAT,Description=\"Frequency of ALT\"\n")
            fw.write("##FORMAT=<ID=DR2>,Number=A,Type=FLOAT,Description=\"Imputation INFO score\"\n")
            fw.write("##FORMAT=<ID=SS>,Number=A,Type=FLOAT,Description=\"Sample Size\"\n")
            fw.write("#CHR\tBP\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t")
            fw.write(args.out + "\n")
        else:
            assoc_contents       = line.split()
            chromosome           = assoc_contents[0]
            position             = assoc_contents[1]
            snp                  = assoc_contents[2]
            ref_allele           = assoc_contents[3]
            alt_allele           = assoc_contents[4]
            qual                 = "."
            filter               = "PASS"
            alt_allele_frequency = assoc_contents[6]
            imputation_info      = assoc_contents[7]
            sample_size          = assoc_contents[8]
            effect_size          = assoc_contents[9]
            standard_error       = assoc_contents[10]
            negative_logp        = -1 * log10(float(assoc_contents[12]))

            fw.write(chromosome + "\t")
            fw.write(position + "\t")
            fw.write(snp + "\t")
            fw.write(ref_allele + "\t")
            fw.write(alt_allele + "\t")
            fw.write(qual + "\t")
            fw.write(filter + "\t")
            fw.write("." + "\t")
            fw.write("ES:SE:EP:AFKG"+ "\t")
            fw.write(effect_size + ":")
            fw.write(standard_error + ":")
            fw.write(negative_logp + ":")
            fw.write(alt_allele_frequency + ":")
            fw.write(imputation_info + "\n")

    fr.close()
    fw.close()

if __name__ == '__main__':
    main()