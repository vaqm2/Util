#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $dict = {};
my $fh = IO::File->new("$ARGV[0]");

while(my $line = $fh->getline)
{
    chomp($line);
    $line =~ s/^\s+//;
    my @lineContents = split(/\s+/, $line);
    my $snp_id = $lineContents[1];
    my $a1 = $lineContents[2];
    my $a2 = $lineContents[3];

    if(length($a1) > 1 || length($a2) > 1)
    {
        next;
    }

    if(exists $dict->{$snp_id})
    {
        next;
    }

    print $line."\n";
    $dict->{$snp_id]} = 1;
}

$fh->close;