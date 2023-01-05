#!/usr/bin/env perl

use strict;
use warnings;
use Bio::DB::HTS::Tabix;
use IO::File;

my $fh = IO::File->new($ARGV[1]) || die "Cannot open z file: $ARGV[1]!\n";
my $vcf = Bio::DB::HTS::Tabix->new(filename => $ARGV[0]) || die "Cannot open vcf.gz file: $ARGV[0]!\n";

while(my $line = $fh->getline) {
    chomp($line);
    if($line =~ /^rsid/) {
        next;
    }
    else {
        my @lineContents = split(/\s+/, $line);
        my $chromosome   = $lineContents[1];
        my $position     = $lineContents[2];
        my $query        = $vcf->query("$chromosome:$position-$position");

        while(my $match = $query->next) {
            my @matchContents = split(/\t/, $match);
            my @infoContents = split(/\;/, $matchContents[7]);
            my $alleleCount  = $infoContents[2];
            my $alleleNumber = $infoContents[3];
            my $maf          = $alleleCount/$alleleNumber;

            if($maf > 0.5) {
                $maf = 1 - $maf;
            }

            print $line." ".$maf."\n";
        }
    }
}

$fh->close;
$vcf->close;