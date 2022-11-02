#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new($ARGV[0]);

while(my $line = $fh->getline) {
    chomp($line);
    if($line =~ /\,/) {
        my @lineContents = split(/\s+/, $line);
        my $chromosome   = $lineContents[0];
        my $start        = $lineContents[1];
        my $end          = $lineContents[2];
        my @snps         = split(/\,/, $lineContents[3]);
        my @positions    = split(/\,/, $lineContents[4]);
        my @p_vals       = split(/\,/, $lineContents[5]);
        my $min_p        = $p_vals[0];
        my $min_p_index  = 0;

        for my $index(1..$#p_vals) {
            if($p_vals[$index] < $min_p) {
                $min_p       = $p_vals[$index];
                $min_p_index = $index;
            }
        }

        print $chromosome."\t";
        print $start."\t";
        print $end."\t";
        print $snps[$min_p_index]."\t";
        print $positions[$min_p_index]."\t";
        print $p_vals[$min_p_index]."\n";
    }
    else {
        print $line."\n";
    }
}

$fh->close;