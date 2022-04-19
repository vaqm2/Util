#!/bin/sh

#SBATCH --account=cross_disorder_2
#SBATCH --mem=64g 
#SBATCH --time=120:00:00

sumstats=$1
bfile=$2
n=$3
chr=$4
start=$5
end=$6
out=$7

mkdir -p ${out}_${chr}_${start}_${end}_susie_ld_cache

python /faststorage/jail/project/cross_disorder_2/scripts/polyfun/finemapper.py \
    --geno ${bfile} \
    --sumstats ${sumstats} \
    --n ${n} \
    --chr ${chr} \
    --start ${start} \
    --end ${end} \
    --method susie \
    --max-num-causal 5 \
    --cache-dir ${out}_${chr}_${start}_${end}_susie_ld_cache \
    --out $out.SUSIE.${chr}.${start}.${end}.gz \
    --non-funct