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
        print "FREQ"."\t";
        print "BETA"."\t";
        print "SE"."\t";
        print "P"."\n";
        next;
    }
    else
    {
        my @lineContents = split(/\s+/, $line);
        my $snp          = $lineContents[0];
        my $a1           = $lineContents[1];
        my $a2           = $lineContents[2];
        my $freq         = $lineContents[3];
        my $beta         = $lineContents[7];
        my $se           = $lineContents[8];
        my $p            = $lineContents[9];

        if(!exists $dict->{$snp})
        {
            print STDERR "ERROR: $snp not found!\n";
            exit;
        }

        print $dict->{$snp}->{chr}."\t";
        print $dict->{$snp}->{pos}."\t";
        print $snp."\t";
        print $a1."\t";
        print $a2."\t";
        print $freq."\t";
        print $beta."\t";
        print $se."\t";
        print $p."\n";
    }
}

$nh->close;