#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $dict = {};

open(IN, "zcat $ARGV[0] |");

while(<IN>)
{
    my $line = $_;
    chomp($line);
    $line =~ s/^\s+//;

    if($line =~ /^SNP/)
    {
        print $line."\n";
        next;
    }

    my @lineContents = split(/\s+/, $line);
    my $snp_id       = $lineContents[0];
    my $a1           = $lineContents[3];
    my $a2           = $lineContents[4];

    if(length($a1) > 1 || length($a2) > 1)
    {
        next;
    }

    if(exists $dict->{$snp_id})
    {
        next;
    }

    print $line."\n";
    $dict->{$snp_id} = 1;
}

close(IN);