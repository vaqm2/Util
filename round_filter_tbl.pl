#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new($ARGV[0]);

while(my $line = $fh->getline) {
    chomp($line);
    if($line =~ /^CHR/) {
        print $line."\n";
        next;
    }
    else {
        my @lineContents = split(/\s+/, $line);
        my $chromosome   = $lineContents[0];
        my $position     = $lineContents[1];
        my $snp          = $lineContents[2];
        my $a1           = $lineContents[3];
        my $a2           = $lineContents[4];
        my $freq         = sprintf("%.2f", $lineContents[5]);
        my $beta         = $lineContents[6];
        my $se           = $lineContents[7];
        my $p            = $lineContents[8];

        if($freq >= 0.01 && $freq <= 0.99) {
            print $chromosome." ";
            print $position." ";
            print $snp." ";
            print $a1." ";
            print $a2." ";
            print $freq." ";
            print $beta." ";
            print $se." ";
            print $p."\n";
        }
        else {
            next;
        }
    }
}

$fh->close;