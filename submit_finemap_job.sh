#!/bin/sh

#SBATCH --account=cross_disorder_2
#SBATCH --mem=64g 
#SBATCH --time=24:00:00

sumstats=$1
bfile=$2
n=$3
chr=$4
start=$5+1500000
end=$5-1500000
out=$6

mkdir -p ${out}_finemap_ld_cache
gzip $sumstats

python /faststorage/jail/project/cross_disorder_2/scripts/polyfun/finemapper.py \
    --geno ${bfile} \
    --sumstats ${sumstats}.gz \
    --n ${n} \
    --chr {$chr} \
    --start ${start} \
    --end ${end} \
    --method finemap \
    --max-num-causal 5 \
    --cache-dir ${out}_finemap_ld_cache \
    --finemap-exe /faststorage/jail/project/cross_disorder_2/scripts/finemap_v1.4.1_x86_64 \
    --out output/${out}.FINEMAP.${chr}.${start}.${end}.gz