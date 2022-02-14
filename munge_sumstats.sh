#!/usr/bin/bash

#SBATCH --account=cross_disorder_2
#SBATCH --mem=8g
#SBATCH --time=04:00:00

python /faststorage/jail/project/cross_disorder_2/scripts/ldsc/munge_sumstats.py \
--sumstats ${1} \
--N ${2} \
--out ${3} \
--merge-alleles /faststorage/jail/project/cross_disorder_2/data/GenomicSEMFiles/w_hm3.snplist