#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new($ARGV[0]) || die "ERROR: Cannot open file: $ARGV[0]\n!!";

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $sumstats     = $lineContents[0];
    my $prefix       = $lineContents[0];
    $prefix          = s/\.parquet$//;
    my @regions      = split(/\_/, $lineContents[1]);
    my $chr          = $regions[0];
    my $start        = $regions[1];
    my $end          = $regions[2];
    my $ext          = $prefix."_".$chr."_".$start."_".$end;
    my $n            = $lineContents[2];

    if($start < 0) {
        $start = 0;
    }

    my $sys_command = "sbatch --error=${ext}.err --output=${ext}.out --job-name=$ext";
    $sys_command   .= " --mem=80g --time=12:00:00 --account=cross_disorder_2";
    $sys_command   .= " --wrap=\"python /faststorage/jail/project/cross_disorder_2/scripts/polyfun/finemapper.py";
    $sys_command   .= " --sumstats $sumstats --chr $chr --n $n --start $start --end $end --method susie";
    $sys_command   .= " --max-num-causal 5 --out ${ext}.PIPs.txt --non-funct --memory 80";
    $sys_command   .= " --cache-dir Finemapper_LD_Cache --verbose --allow-missing";
    $sys_command   .= " --geno /faststorage/jail/project/ibp_data_ipsych/ipsych_2012/iPSYCH_IBP_Imputed_v_2.1/qced/plink1/";
    $sys_command   .= "iPSYCH2012.PhaseBEAGLE5.1PhaseStates560ImputeBEAGLE5.1.chr${chr}.SNP_SAMPLE_QC.UpdatedRSID.1\"";

    `$sys_command`;
}

$fh->close;