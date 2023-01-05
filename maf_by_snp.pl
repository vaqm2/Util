#!/usr/bin/env perl

use strict;
use warnings;
use Bio::DB::HTS::Tabix;
use IO::File;

my @name = split(/\_/, $ARGV[0]);
my $chr  = $name[$#name - 2];

my $vcf_file = "/faststorage/jail/project/ibp_data_ipsych/ipsych_2012/iPSYCH_IBP_Imputed_v_2.1/qced/vcf/"
$vcf_file   .= "iPSYCH2012.PhaseBEAGLE5.1PhaseStates560ImputeBEAGLE5.1.chr".$chr;
$vcf_file   .= ".SNP_SAMPLE_QC.UpdatedRSID.1.vcf.gz";

my $fh = IO::File->new($ARGV[0]) || die "Cannot open z file: $ARGV[0]!\n";
my $vcf = Bio::DB::HTS::Tabix->new(filename => $vcf_file) || die "Cannot open vcf.gz file: $vcf_file!\n";

while(my $line = $fh->getline) {
    chomp($line);
    if($line =~ /^rsid/) {
        next;
    }
    else {
        my @lineContents = split(/\s+/, $line);
        my $snp          = $lineContents[0];
        my $chromosome   = $lineContents[1];
        my $position     = $lineContents[2];
        my $query        = $vcf->query("$chromosome:$position-$position");

        while(my $match = $query->next) {
            my @matchContents = split(/\t/, $match);
            my @infoContents  = split(/\;/, $matchContents[7]);
            my $alleleCount   = $infoContents[$#infoContents - 1];
            $alleleCount      =~ s/^AC\=//;
            my $alleleNumber  = $infoContents[$#infoContents];
            $alleleNumber     =~ s/^AN\=//;
            my $maf           = $alleleCount/$alleleNumber;

            if($maf > 0.5) {
                $maf = 1 - $maf;
            }

            if($maf >= 0.01) {
                print $snp."\n";
            }
        }
    }
}

$fh->close;
$vcf->close;