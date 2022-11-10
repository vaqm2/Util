#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $sumstats = $ARGV[0];
my $regions  = $ARGV[1];
my $n        = $ARGV[2];
my $prefix   = $sumstats;
$prefix      =~ s/\.parquet//;

my $fh = IO::File->new($ARGV[1]) || die "ERROR: Cannot open regions file: $ARGV[1]\n!!";

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $chr          = $lineContents[0];
    my $start        = $lineContents[1];
    my $end          = $lineContents[2];
    $prefix         .= "_".$chr."_".$start."_".$end;

    if($start < 0) {
        $start = 0;
    }

    my $sys_command = "sbatch --error=${prefix}.err --output=${prefix}.out --job-name=$prefix";
    $sys_command   .= " --mem=32g --time=12:00:00 --account=cross_disorder_2";
    $sys_command   .= " --wrap=\"python /faststorage/jail/project/cross_disorder_2/scripts/polyfun/finemapper.py";
    $sys_command   .= " --sumstats $sumstats --chr $chr --n $n --start $start --end $end --method susie";
    $sys_command   .= " --max-num-causal 5 --out ${prefix}.PIPs.txt --non-funct --memory 32";
    $sys_command   .= " --cache-dir Finemapper_LD_Cache --verbose --allow-missing";
    $sys_command   .= " --geno /faststorage/jail/project/ibp_data_ipsych/ipsych_2012/iPSYCH_IBP_Imputed_v_2.1/qced/plink1/";
    $sys_command   .= "iPSYCH2012.PhaseBEAGLE5.1PhaseStates560ImputeBEAGLE5.1.chr${chr}.SNP_SAMPLE_QC.UpdatedRSID.1\"";

    print "$sys_command"."\n";
    $prefix = "";
}