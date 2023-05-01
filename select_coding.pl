#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new("$ARGV[0]") || die "Cannot open file: $ARGV[0]!\n";
my $map = {};

while(my $line = $fh->getline) {
    chomp($line);
    if($line =~ /^ensembl_gene_id/) {
        next;
    }
    else {
        my @lineContents = split(/\s+/, $line);
        my $ensembl_id   = $lineContents[0];
        my $hgnc_symbol  = $lineContents[1];
        my $geneType     = $lineContents[7];

        if($geneType eq "protein_coding") {
            if($hgnc_symbol == "") {
                print STDERR "Skipping gene symbol: $ensembl_id due to missing HGNC ID\n";
            }
            else {
                $map->{$ensembl_id} = $hgnc_symbol;
            }
        }
        else {
            next;
        }
    }
}

$fh->close;

$fh = IO::File->new("$ARGV[1]") || die "Cannot open file: $ARGV[1]!\n";

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $ensembl_id   = $lineContents[0];

    if(exists $map->{$ensembl_id}) {
        print $map->{$ensembl_id};

        for my $index(0..$#lineContents) {
            print "\t".$lineContents[$index];
        }

        print "\n";
    }
    else {
        next;
    }
}

$fh->close;