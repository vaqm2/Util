#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $snps   = {};
my $header = "";

my $fh = IO::File->new("$ARGV[0]") || die "Cannot open association file: $ARGV[0]"."!!\n";

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $chromosome   = $lineContents[0];
    my $position     = $lineContents[3];
    my $a1           = $lineContents[4];
    my $a2           = $lineContents[5];
    my $key         .= $chromosome.".";
    $key            .= $position.".";
    $key            .= $a1.".";
    $key            .= $a2;

    if(exists $snps->{$key}) {
        print $snp."\n";
    }
    else {
        next;
    }
}

$fh->close;