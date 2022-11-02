#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $sumstats      = $ARGV[0];
my $ld_matrix     = $ARGV[1];
my $n             = $ARGV[2];
my $ld_mat_prefix = $ld_matrix;
$ld_mat_prefix    =~ s/\.bcor$//;
my @coords        = split(/\_/, $ld_mat_prefix);
my $chr           = $coords[$#coords - 2];
my $start         = $coords[$#coords - 1];
my $end           = $coords[$#coords];

if($start < 0) {
    $start = 0;
}

my $sys_command = "sbatch --error=$ld_mat_prefix.err --output=$ld_mat_prefix.out --job-name=$ld_mat_prefix";
$sys_command   .= " --mem=32g --time=08:00:00 --account=cross_disorder_2";
$sys_command   .= " --wrap=\"python /faststorage/jail/project/cross_disorder_2/scripts/polyfun/finemapper.py";
$sys_command   .= " --sumstats $sumstats --chr $chr --n $n --start $start --end $end --method susie";
$sys_command   .= " --max-num-causal 5 --out $ld_mat_prefix --non-funct --memory 32";
$sys_command   .= " --cache-dir Finemapper_LD_Cache --verbose --allow-missing --ld BCOR/$ld_matrix\"";

`$sys_command`;