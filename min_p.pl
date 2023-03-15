#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $snps = {};

my $fh = IO::File->new($ARGV[0]);

while(my $file_name = $fh->getline) {
    chomp($file_name);
    my $assoc_file = IO::File->new($file_name);

    while(my $line = $assoc_file->getline) {
        chomp($line);
        if($line =~ /^SNP/) {
            next;
        }
        else {
            my @lineContents = split(/\s+/, $line);
            my $snp = $lineContents[0];
            my $chr = $lineContents[1];
            my $bp = $lineContents[2];
            my $p = $lineContents[8];

            if(!exists $snps->{$snp}) {
                $snps->{$snp}->{chr} = $chr;
                $snps->{$snp}->{bp} = $bp;
                $snps->{$snp}->{p} = $p;
                $snps->{$snp}->{assoc} = $file_name;
            }
            else {
                if($snps->{$snp}->{p} > $p) {
                    $snps->{$snp}->{p} = $p;
                    $snps->{$snp}->{assoc} = $file_name;
                }
            }
        }
    }

    $assoc_file->close;
}

$fh->close;