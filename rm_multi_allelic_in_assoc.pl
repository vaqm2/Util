#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $snps   = {};
my $header = "";

my $fh = IO::File->new("$ARGV[0]") || die "Cannot open association file: $ARGV[0]"."!!\n";

while(my $line = $fh->getline) {
    chomp($line);
    if($line =~ /^CHR/i) {
        $header = $line;
        next;
    }
    else {
        my @lineContents = split(/\s+/, $line);
        my $chromosome   = $lineContents[0];
        my $position     = $lineContents[1];
        my $a1           = $lineContents[3];
        my $a2           = $lineContents[4];
        my $key         .= $chromosome.".";
        $key            .= $position.".";
        $key            .= $a1.".";
        $key            .= $a2;
        my $p_val        = $lineContents[8];

        if(exists $snps->{$key} && $snps->{$key}->{p_val} < $p_val) {
            next;
        }
        else {
            $snps->{$key}->{p_val} = $p_val;
            $snps->{$key}->{line}  = $line;
        }
    }
}

$fh->close;

print $header."\n";

for my $index(sort keys %$snps) {
    print $snps->{$index}->{line}."\n";
}