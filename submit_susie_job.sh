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

mkdir ${out}_susie_ld_cache
gzip $sumstats


python finemapper.py \
    --geno ${bfile} \
    --sumstats ${sumstats}.gz \
    --n ${n} \
    --chr {$chr} \
    --start ${start} \
    --end ${end} \
    --method susie \
    --max-num-causal 5 \
    --cache-dir ${out}_ld_susie_cache \
    --out output/$out.SUSIE.${chr}.${start}.${end}.gz