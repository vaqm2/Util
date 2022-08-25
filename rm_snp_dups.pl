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
    my $chr          = $lineContents[1];
    my $position     = $lineContents[2];
    my $a1           = $lineContents[3];
    my $a2           = $lineContents[4];
    my $key          = $chr."_".$position."_".$a1."_".$a2;

    if(length($a1) > 1 || length($a2) > 1)
    {
        next;
    }

    if(exists $dict->{$key})
    {
        next;
    }

    print $line."\n";
    $dict->{$key} = 1;
}

close(IN);