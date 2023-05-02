#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fof    = IO::File->new($ARGV[0]) || die "Error: Cannot open $ARGV[0]!\n";
my $genes  = {};

while(my $line = $fof->getline) {
    chomp($line);
    
    my $fh = IO::File->new($line) || die "Error: Cannot open Magma assoc file: file!\n";

    while(my $line = $fh->getline) {
        chomp($line);
        my $gwas = $line;
        $gwas =~ s/\.genes\.out$//;
        $gwas =~ s/^iPSYCH2015\_EUR\_//;

        print "Processing $line .."."\n";
        
        if($line =~ /^GENE/) {
            next;
        }
        else {
            my @lineContents = split(/\s+/, $line);

            my $gene    = $lineContents[0];
            my $p_value = $lineContents[8];

            if(!exists $genes->{$gene}) {
                $genes->{$gene}->{chr}    = $lineContents[1];
                $genes->{$gene}->{start}  = $lineContents[2];
                $genes->{$gene}->{stop}   = $lineContents[3];
                $genes->{$gene}->{min_p}  = $p_value;
                $genes->{$gene}->{pheno}  = "-";
            }
            else {
                if($p_value < $genes->{$gene}->{min_p}) {
                    $genes->{$gene}->{min_p} = $p_value;
                }
            }
            if($p_value <= 2.5e-5) {
                $genes->{$gene}->{pheno} .= ";".$gwas;
            }
        }
    }

    $fh->close;
}

$fof->close;

print "GENE\tCHR\tSTART\tSTOP\tP\tPHENOTYPE\n";

for my $index(keys %$genes) {
    print $index."\t";
    print $genes->{$index}->{chr}."\t";
    print $genes->{$index}->{start}."\t";
    print $genes->{$index}->{stop}."\t";
    print $genes->{$index}->{min_p};

    if($genes->{$index}->{pheno} ne "-") {
        $genes->{$index}->{pheno} =~ s/^\-\;//;
    }

    print $genes->{$index}->{pheno}."\n";
}