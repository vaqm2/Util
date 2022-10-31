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
            fw.write("##fileDate=" + date.today().strftime("%Y%m%d") + "\n")
            fw.write("##source=saige_to_vcf.py\n")
            fw.write("##FORMAT=<ID=ES,Number=A,Type=Float,Description=\"Effect Size of ALT\">\n")
            fw.write("##FORMAT=<ID=SE,Number=A,Type=Float,Description=\"Standard Error of Effect Size\">\n")
            fw.write("##FORMAT=<ID=EP,Number=A,Type=Float,Description=\"P-value of Effect Size\">\n")
            fw.write("##FORMAT=<ID=AFKG,Number=A,Type=Float,Description=\"Frequency of ALT\">\n")
            fw.write("##FORMAT=<ID=DR2,Number=A,Type=Float,Description=\"Imputation INFO score\">\n")
            fw.write("##FORMAT=<ID=SS,Number=A,Type=Float,Description=\"Sample Size\">\n")
            fw.write("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t")
            fw.write(args.out + "\n")
        else:
            assoc_contents       = line.split()
            chromosome           = assoc_contents[0]
            position             = assoc_contents[1]
            snp                  = assoc_contents[2]
            ref_allele           = assoc_contents[3]
            alt_allele           = assoc_contents[4]
            filter               = "PASS"
            alt_allele_frequency = assoc_contents[6]
            imputation_info      = assoc_contents[7]
            sample_size          = assoc_contents[8]
            effect_size          = assoc_contents[9]
            standard_error       = assoc_contents[10]
            p_value              = assoc_contents[12]

            fw.write(chromosome + "\t")
            fw.write(position + "\t")
            fw.write(snp + "\t")
            fw.write(ref_allele + "\t")
            fw.write(alt_allele + "\t")
            fw.write("." + "\t")
            fw.write(filter + "\t")
            fw.write("." + "\t")
            fw.write("ES:SE:EP:AFKG:DR2:SS"+ "\t")
            fw.write(effect_size + ":")
            fw.write(standard_error + ":")
            fw.write(p_value + ":")
            fw.write(alt_allele_frequency + ":")
            fw.write(imputation_info + ":")
            fw.write(sample_size + "\n")

    fr.close()
    fw.close()

if __name__ == '__main__':
    main()