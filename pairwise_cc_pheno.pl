#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;
use Getopt::Long;

sub usage() {
    print "Missing required files!"."\n"; 
    print "\n"."USAGE: perl $0 --pheno1 <Phenotype1.txt> --pheno2 <Phenotype2.txt> --out <Output.txt>"."\n\n";
    exit;
}

sub read_phenotypes {
    my $file = shift;
    my $dict = {};

    my $fh = IO::File->new($file) || die "ERROR: Phenotype file $file not found!!"."\n";

    while(my $line = $fh->getline) {
        chomp($line);

        if($line =~ /^IID/i) {
            next;
        }
        else {
            my @lineContents = split(/\s+/, $line);
            my $iid          = $lineContents[0];
            my $phenotype    = $lineContents[$#lineContents];

            if($phenotype == 0) {
                next;
            }
            else {
                $dict->{$iid}    = $line;
            }
        }
    }

    $fh->close;
    return $dict;
}

my ($pheno1, $pheno2, $out);

if(length($pheno1) == 0 || length($pheno2) == 0 || length($out) == 0) {
    usage();
}


GetOptions(
    "pheno1=s" => \$pheno1,
    "pheno2=s" => \$pheno2,
    "out=s" => \$out
);

my $pheno1_dict = read_phenotypes($pheno1);
my $pheno2_dict = read_phenotypes($pheno2);
my $out_fh = IO::File->new("> $out") || die "ERROR: Cannot create output file: $out"."!!\n";

print $out_fh "IID"." ";
print $out_fh "Age"." ";
print $out_fh "Sex"." ";

for (my $i = 1; $i <= 10; $i++) { 
    print $out_fh "PC".$i." ";
}

print $out_fh "PHENOTYPE"."\n";

for my $index(keys %$pheno1_dict) {
    if(exists $pheno2_dict->{$index}) {
        next;
    }
    else {
        $pheno1_dict->{$index} =~ s/\s+/" "/;
        print $out_fh $pheno1_dict->{$index}."\n";
    }
}

for my $index(keys %$pheno2_dict) {
    if(exists $pheno1_dict->{$index}) {
        next;
    }
    else {
        my @lineContents = split(/\s+/, $pheno2_dict->{$index});
        my $phenotype = $lineContents[$#lineContents] - 1;

        for my $line_index(0..($#lineContents - 1)) {
            print $out_fh $lineContents[$line_index]." ";
        }

        print $out_fh $phenotype."\n";
    }
}

$out_fh->close;