#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $snps  = {};
my $stats = {};
my @studies;
my $data_dir = "/faststorage/project/xdx2/data";
my $fh = IO::File->new("$ARGV[0]") || die "ERROR: Cannot open file: $ARGV[0]!\n\n";

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents = split(/\,/, $line);
    my $rsid         = $lineContents[0];
    $snps->{$rsid}   = 1;
}

$fh->close;

$fh = IO::File->new("$ARGV[1]") || die "ERROR: Cannot open file: $ARGV[1]!\n\n";

while(my $line = $fh->getline) {
    chomp($line);

    my $nh   = IO::File->new("$data_dir/$line") || die "ERROR: Cannot open file: $data_dir/$line!\n\n";
    my $gwas = $line;
    $gwas    =~ s/\.assoc$//;
    $gwas    =~ s/^iPSYCH2015\_EUR\_//;
    push(@studies, $gwas);

    while(my $assoc_line = $nh->getline) {
       if($line =~ /^SNP/) {
        next;
       } 
       else {
        my @assocContents = split(/\s+/, $assoc_line);
        my $rsid          = $assocContents[0];
        my $beta          = $assocContents[6];
        my $p_val         = $assocContents[7];
        my $z_score       = $assocContents[8];

        if(exists $snps->{$rsid}) {
            $stats->{$rsid}->{$gwas}->{beta} = $beta;
            $stats->{$rsid}->{$gwas}->{p}    = $p_val;
            $stats->{$rsid}->{$gwas}->{z}    = $z_score;
        }
        else {
            next;
        }
       }
    }
    $nh->close;
}

$fh->close;

print "SNP\tGWAS\tB\tP\tZ\n";

for my $index(sort keys %$stats) {
    for my $idx2(0..$#studies) {
        print $index."\t";
        print $studies[$idx2]."\t";
        print $stats->{$index}->{$studies[$idx2]}->{beta}."\t";
        print $stats->{$index}->{$studies[$idx2]}->{p}."\t";
        print $stats->{$index}->{$studies[$idx2]}->{z}."\n";
    }
}