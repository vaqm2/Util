#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $outFile = $ARGV[0];
$outFile =~ s/^.*UpdatedRSID\.//;
$outFile =~ s/\.gz$//;
$outFile =~ s/\./\_/g;
$outFile = "iPSYCH2015_".$outFile.".z";

my $out = IO::File->new("> $outFile") || die "FATAL: Cannot write to output file: $outFile!\n";
open(IN, "zcat $ARGV[0] |");

while(<IN>) {
    print $out $_;
}

close(IN);