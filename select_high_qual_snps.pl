#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $usage = "\n\nUSAGE: perl $0 snp_metrics1.txt snp_metrics2.txt GWAS.assoc\n\n";

if(!$ARGV[0] || !$ARGV[1] || !$ARGV[2]) {
    print $usage;
    exit;
}

my $high_quality_snps = {};

open(IN, "zcat $ARGV[0] |");

while(<IN>) {
    chomp($_);
    my @lineContents = split(/\s+/, $_);
    my $chrom        = $lineContents[0];
    my $position     = $lineContents[1];
    my $snp_id       = $lineContents[2];
    my $ref          = $lineContents[3];
    my $alt          = $lineContents[4];
    my $maf          = $lineContents[5];
    my $dr2          = $lineContents[7];

    if($maf > 0.5) {
        $maf = 1 - $maf;
    }

    if($maf >= 0.01 && $dr2 >= 0.6) {
        $high_quality_snps->{$snp_id} = 1; 
    }
}

close(IN);

open(IN, "zcat $ARGV[1] |");

while(<IN>) {
    chomp($_);
    my @lineContents = split(/\s+/, $_);
    my $chrom        = $lineContents[0];
    my $position     = $lineContents[1];
    my $snp_id       = $lineContents[2];
    my $ref          = $lineContents[3];
    my $alt          = $lineContents[4];
    my $maf          = $lineContents[5];
    my $dr2          = $lineContents[7];

    if(!exists $high_quality_snps->{$snp_id}) {
        next;
    }

    if($maf > 0.5) {
        $maf = 1 - $maf;
    }

    if($maf > 0.01 && $dr2 >= 0.6) {
        $high_quality_snps->{$snp_id} += 1;
    }
}

close(IN);

my $fh = IO::File->new($ARGV[2]);

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $snp_id = $lineContents[2];

    if(!exists $high_quality_snps->{$snp_id}) {
        next;
    }

    if($high_quality_snps->{$snp_id} == 1) {
        next;
    }

    if($high_quality_snps->{$snp_id} > 2) {
        print STDERR "WARN: Duplicate SNP: $snp_id"."\n";
    }

    if($high_quality_snps->{$snp_id} == 2) {
        print $line."\n";
    }
}

$fh->close;