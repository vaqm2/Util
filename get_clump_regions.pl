#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;
use Getopt::Long;
use List::Util qw(min max);

my ($clump, $bim);

GetOptions("clump=s" => \$clump,
    "bim=s" => \$bim);

my $usage = "\nUSAGE: perl $0 --clump plink.clumped --bim reference.bim\n\n";

unless($clump && $bim) {
    print $usage;
    exit;
}

my $snp_coordinates = {};

my $fh = IO::File->new($bim) || die "FATAL: Cannot open BIM file: $bim"."!!\n";

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $snp = $lineContents[1];
    print "Loading SNP: $snp\n";
    $snp_coordinates->{$snp} = $lineContents[3];
}

$fh->close;

my $nh = IO::File->new($clump) || die "FATAL: Cannot open clumped file: $clump"."!!\n";

print "INDEX_SNP"." ";
print "CHR"." ";
print "BP"." ";
print "P"." ";
print "N_TAGS"." ";
print "START"." ";
print "END"."\n";

while(my $line = $nh->getline) {
    chomp($line);
    if($line =~ /^CHR/) {
        next;
    }
    else {
        my @lineContents = split(/\s+/, $line);
        print $lineContents[2]." ";
        print $lineContents[0]." ";
        print $lineContents[3]." ";
        print $lineContents[4]." ";
        print $lineContents[6]." ";

        if($lineContents[11] eq "NONE") {
            print $lineContents[3]." ";
            print $lineContents[3];
        }
        else {
            my @tags = split(/\,/, $lineContents[11]);
            my @tag_coordinates;

            for my $index(0..$#tags) {
                $tags[$index] =~ s/\(.*$//;
                if(exists $snp_coordinates->{$tags[$index]}) {
                    $tag_coordinates[$index] = $snp_coordinates->{$tags[$index]};
                }
                else {
                    die "FATAL: Cannot find coordinate for tag SNP: $tags[$index]"."!!\n";
                }
            }

            my $start = max(@tag_coordinates);
            my $end = min(@tag_coordinates);

            print $start." ";
            print $end;
        }
        print "\n";
    }
}

$nh->close;