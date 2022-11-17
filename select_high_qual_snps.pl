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

    if($_ =~ /^CHROM/) {
        next;
    }

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

    if($_ =~ /^CHROM/) {
        next;
    }
    
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

print "SNP CHR BP A1 A2 MAF BETA SE P Z"."\n";

my $fh = IO::File->new($ARGV[2]);

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents  = split(/\s+/, $line);
    my $chromosome    = $lineContents[0];
    my $bp            = $lineContents[1];
    my $snp_id        = $lineContents[2];
    my $a1            = $lineContents[3];
    my $a2            = $lineContents[4];
    my $beta_a1_saige = -1 * $lineContents[6];
    my $se            = $lineContents[7];
    my $p_val         = $lineContents[8];
    my $z_a1_saige    = $beta_a1_saige/$se;
    $z_a1_saige       = sprintf("%0.4f", $z_a1_saige);
    my $maf           = $lineContents[9];

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
        print $snp_id." ";
        print $chromosome." ";
        print $bp." ";
        print $a1." ";
        print $a2." ";
        print $maf." ";
        print $beta_a1_saige." ";
        print $se." ";
        print $p_val." ";
        print $z_a1_saige."\n";
    }
}

$fh->close;