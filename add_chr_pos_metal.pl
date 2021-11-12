#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $bim  = IO::File->new("$ARGV[0]"); # BIM FILE
my $dict = {};

while(my $line = $bim->getline)
{
    chomp($line);
    my @lineContents     = split(/\s+/, $line);
    my $chromosome       = $lineContents[0];
    my $snp              = $lineContents[1];
    my $position         = $lineContents[3];
    $dict->{$snp}->{chr} = $chromosome;
    $dict->{$snp}->{pos} = $position;
}

$bim->close;

my $nh = IO::File->new("$ARGV[1]"); # METAL OUTPUT

while(my $line = $nh->getline)
{
    chomp($line);
    if($line =~ /^Marker/)
    {
        print "CHR"."\t";
        print "BP"."\t";
        print "SNP"."\t";
        print "A1"."\t";
        print "A2"."\t";
        print "N"."\t";
        print "Z"."\t";
        print "P"."\t";
        print "DIRECTION"."\n";
    }
    else
    {
        my @lineContents = split(/\s+/, $line);
        my $snp          = $lineContents[0];

        if(!exists $dict->{$snp})
        {
            print "ERROR: $snp not found!\n";
            exit;
        }

        print $dict->{$snp}->{chr}."\t";
        print $dict->{$snp}->{pos}."\t";
    }

    print $line."\n";
}

$nh->close;