#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new("$ARGV[0]");
my $work_dir_prefix = "/faststorage/jail/project/cross_disorder_2/people/vivapp/PGS";
my $pipeline_dir = "/faststorage/jail/project/proto_psych_pgs/scripts/ibp_pgs_pipelines";

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents = split(/\,/, $line);
    my $reference    = $lineContents[0];
    my $target       = $lineContents[1];
    my $n            = $lineContents[2];
    my $n_cases      = $lineContents[3];

    print "sbatch --mem=8g --time=48:00:00 --account=cross_disorder_2 --error=${reference}.err --output=${reference}.out --job-name=${reference} --chdir=${work_dir_prefix}/${reference}/ --wrap=\"nextflow run ${pipeline_dir}/main.nf --ref ${work_dir_prefix}/${reference}/${reference}.vcf.gz --target ${target} --trait ${reference} --pheno ${work_dir_prefix}/phenotype.txt --binary T --prevalence 0.01 --n $n --n_cases $n_cases\"\n";
}