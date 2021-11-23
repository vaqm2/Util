#!/usr/bin/env perl

use strict;
use warnings;

my $dict = {};

while(<>)
{
    my $line = chomp($_);
    my @lineContents = split(/\s+/, $line);
    my $snp_id = $lineContents[1];

    if(exists $dict->{$snp_id})
    {
        next;
    }
    else
    {
        print $line."\n";
    }
}