#/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new($ARGV[0]) || die "ERROR: Cannot open file: $ARGV[0]!\n";

while(my $line = $fh->getline) {
    chomp($line);
    if($line =~ /^PHENO/) {
        next;
    }
    else {
        my @lineContents = split(/\,/, $line);
        my $trait_name = $lineContents[0];
        my $cohort = $lineContents[1];
        my $n_cases = $lineContents[2];
        my $n_samples = $lineContents[3];

        if($cohort eq "2015") {
            my $cmd = "python /faststorage/project/xdx2/scripts/ldsc/munge_sumstats.py";
            $cmd .= " --sumstats /faststorage/project/xdx2/data/assoc/iPSYCH2015_EUR_${trait_name}.assoc";
            $cmd .= " --N $n_samples";
            $cmd .= " --N-cas $n_cases";
            $cmd .= " --a1 A1";
            $cmd .= " --a2 A2";
            $cmd .= " --p P";
            $cmd .= " --frq MAF";
            $cmd .= " --signed-sumstats Z,0";
            $cmd .= " --a1-inc";
            $cmd .= " --merge-alleles /faststorage/project/xdx2/data/w_hm3.snplist";
            $cmd .= " --out iPSYCH2015_EUR_${trait_name}";
            $cmd .= " --chunksize 50000";

            `sbatch --error=munge_${trait_name}.err --output=munge_${trait_name}.out --job-name=munge_${trait_name} --mem=8g --time=04:00:00 --account=xdx2 --wrap=\"$cmd\";`
        }
    }
}

$fh->close;