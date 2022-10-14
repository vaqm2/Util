#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;
use Getopt::Long;
use List::Util qw(min max);

my ($clump, $bim);

GetOptions(
    "clump=s" => \$clump,
    "bim=s"   => \$bim
);

my $usage = "\nUSAGE: perl $0 --clump plink.clumped --bim reference.bim\n\n";

unless($clump && $bim) {
    print $usage;
    exit;
}

my $snp_coordinates = {};

my $fh = IO::File->new($bim) || die "FATAL: Cannot open BIM file: $bim"."!!\n";

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents         = split(/\s+/, $line);
    my $snp                  = $lineContents[1];
    $snp_coordinates->{$snp} = $lineContents[3];
}

$fh->close;

my $nh = IO::File->new($clump) || die "FATAL: Cannot open clumped file: $clump"."!!\n";

print "#CHR"."\t";
print "START"."\t";
print "END"."\t";
print "INDEX_SNP"."\t";
print "BP"."\t";
print "P"."\n";

while(my $line = $nh->getline) {
    chomp($line);
    if($line =~ /^CHR/) {
        next;
    }
    else {
        my @lineContents = split(/\s+/, $line);
        my $chromosome   = $lineContents[0];
        my $index_snp    = $lineContents[2];
        my $bp           = $lineContents[3];
        my $start        = $bp; # Defaults
        my $end          = $bp; # Defaults
        my $p            = $lineContents[4];

        if($lineContents[11] ne "NONE") {
            my @tags = split(/\,/, $lineContents[11]);
            my @tag_coordinates;

            for my $index(0..$#tags) {
                my $tag_snp = $tags[$index];
                $tag_snp    =~ s/\(.*$//;
                if(exists $snp_coordinates->{$tag_snp}) {
                    $tag_coordinates[$index] = $snp_coordinates->{$tag_snp};
                }
                else {
                    die "FATAL: Cannot find coordinate for tag SNP: $tags[$index]"."!!\n";
                }
            }

            $start = min(@tag_coordinates);
            $end   = max(@tag_coordinates);
        }

        print $chromosome."\t";
        print $start."\t";
        print $end."\t";
        print $index_snp."\t";
        print $bp."\t";
        print $p."\n";
    }
}

$nh->close;