#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh         = IO::File->new($ARGV[0]) || die "ERROR: Cannot open query file: $ARGV[0]"."!!\n";
my $vcf_dir    = "/faststorage/jail/project/ibp_data_ipsych/ipsych_2012/iPSYCH_IBP_Imputed_v_2.1/qced/vcf";
my $vcf_prefix = "iPSYCH2012.PhaseBEAGLE5.1PhaseStates560ImputeBEAGLE5.1.chr";
my $vcf_suffix = "SNP_SAMPLE_QC.UpdatedRSID.1.vcf.gz";
my $eur_unrel  = "/faststorage/jail/project/cross_disorder_2/people/vivapp/Finemap/EurUnrel.txt";
my $out_prefix = $ARGV[0];
$out_prefix    =~ s/^.*\///;
$out_prefix    =~ s/\_RegionsToFinemap\.bed$//;

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $chr          = $lineContents[0];
    my $start        = $lineContents[1];
    my $end          = $lineContents[2];

    `bcftools view \
    -S $eur_unrel \
    -r $chr:$start-$end \
    -Oz -o ${out_prefix}_chr${chr}_${start}_${end}.vcf.gz \
    $vcf_dir/${vcf_prefix}${chr}.${vcf_suffix}`;
}

$fh->close;