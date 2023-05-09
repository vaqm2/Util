#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $sumstats    = $ARGV[0];
my $n_cases     = $ARGV[1];
my $n_controls  = $ARGV[2];
my $out         = $ARGV[3];
my $script_path = "python /faststorage/jail/project/cross_disorder_2/scripts/python_convert/sumstats.py";

`$script_path csv --sumstats $sumstats --out ${out}.csv --force --auto --head 5 --ncase-val $n_cases --ncontrol-val $n_controls`;
`$script_path zscore --sumstats ${out}.csv | $script_path qc --exclude-ranges 6:26000000-34000000 --max-or 1e37 |\
$script_path neff --drop --factor 4 --out ${out}_qc_noMHC.csv --force`;
`gzip ${out}_qc_noMHC.csv`;