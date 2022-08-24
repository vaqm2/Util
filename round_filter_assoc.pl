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
        my $ac_a2        = sprintf("%.0f", $lineContents[5]);
        my $af_a2        = sprintf("%.2f", $lineContents[6]);
        my $info         = sprintf("%.2f", $lineContents[7]);
        my $n            = $lineContents[8];
        my $beta         = sprintf("%.2f", $lineContents[9]);
        my $se           = sprintf("%.2f", $lineContents[10]);
        my $t_stat       = sprintf("%.2f", $lineContents[11]);
        my $p1           = $lineContents[12];
        my $p2           = $lineContents[13];
        my $spa          = $lineContents[14];
        my $varT         = sprintf("%.2f", $lineContents[15]);
        my $varTstar     = sprintf("%.2f", $lineContents[16]);
        my $af_cases     = sprintf("%.2f", $lineContents[17]);
        my $af_controls  = sprintf("%.2f", $lineContents[18]);

        if($af_a2 >= 0.01 && $af_a2 <= 0.99) {
            print $chromosome." ";
            print $position." ";
            print $snp." ";
            print $a1." ";
            print $a2." ";
            print $ac_a2." ";
            print $af_a2." ";
            print $info." ";
            print $n." ";
            print $beta." ";
            print $se." ";
            print $t_stat." ";
            print $p1." ";
            print $p2." ";
            print $spa." ";
            print $varT." ";
            print $varTstar." ";
            print $af_cases." ";
            print $af_controls."\n";
        }
        else {
            next;
        }
    }
}   

$fh->close;