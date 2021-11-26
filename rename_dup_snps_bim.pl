#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh   = IO::File->new("$ARGV[0]");
my $dict = {};

while(my $line = $fh->getline)
{
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $chromosome   = $lineContents[0];
    my $snp          = $lineContents[1];
    my $distance     = $lineContents[2];
    my $position     = $lineContents[3];   
    my $a1           = $lineContents[4];
    my $a2           = $lineContents[5];
    my $key         .= $chromosome;
    $key            .= "_".$position;
    $key            .= "_".$a1;
    $key            .= "_".$a2;

    if($snp eq ".")
    {
        $snp = $key;
    }
    else
    {
        if(exists $dict->{$snp})
        {
            $snp .= "_".$a1;
        }
    }  

    print $chromosome." ";
    print $snp." ";
    print $distance." ";
    print $position." ";
    print $a1." ";
    print $a2."\n";

    $dict->{$snp} = 1;
}

$fh->close;