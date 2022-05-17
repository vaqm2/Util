#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $g1k_snps = {};

my $fh = IO::File->new("$ARGV[0]") || die "Cannot open FRE file: $ARGV[0]!"."\n";

while(my $line = $fh->getline) {
    chomp($line);
    if($line =~ /^CHR/) {
        next;
    }
    else {
        my @lineContents = split(/\s+/, $line);
        my $snp = $lineContents[1];
        $g1k_snps->{$snp} = 1;
    }
    
}

$fh->close;

open(IN, "zcat $ARGV[1] |") || die "Cannot open file: $ARGV[1]!"."\n";

while(<IN>) {
    chomp($_);
    if($_ =~ /^CHR/) {
        next;
    }
    else {
        my @lineContents = split(/\s+/, $_);
        my $snp = $lineContents[2];

        if(exists $g1k_snps->{$snp}) {
            next;
        }
        else {
            print $snp." "."Missing!\n";
        }
    }
}

close(IN);