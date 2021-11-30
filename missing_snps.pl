#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new("$ARGV[0]");
my $dict = {};

while(my $line = $fh->getline)
{
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $snp = $lineContents[1];
    $dict->{$snp} = 1;
}

$fh->close;

open(IN, "zcat $ARGV[1] |");

while(<IN>)
{
    chomp($_);
    if($_ =~ /^CHR/)
    {
        next;
    }
    else
    {
        my @lineContents = split(/\s+/, $_);
        my $snp = $lineContents[1];

        if(exists $dict->{$snp})
        {
            next;
        }
        else
        {
            print $snp." Missing"."\n";
        }
    }
}

close(IN);