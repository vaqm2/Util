#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my @files = ("Konrad_Raznahan_Sets", "Konrad_Raznahan_Modules", "DOSE_SENSITIVITY_GENES");
my $sets = {};
my $out = IO::File->new("> Konrad_Raznahan.gmt") || die "ERROR: Cannot create file:Konrad_Raznahan.gmt\n";

for my $index(0..2) {
    print "Processing $files[$index]..\n";
    my $fh = IO::File->new("$files[$index].txt") ||  die "ERROR: Cannot open file: $files[$index].txt\n";

    while(my $line = $fh->getline) {
        chomp($line);
        print "Processing $line ..\n";
        my ($set, $gene) = split(/\s+/, $line);

        if(exists $sets->{$set}) {
            $sets->{$set}->{genes} .= $sets->{$set}->{genes}."\t".$gene;
            next;
        }
        else {
            $sets->{$set}->{genes} = $gene;
            next;
        }
    }

    $fh->close;
}

for my $index(keys %$sets) {
    print $out $index."\t";
    print $out $sets->{$index}->{genes}."\n";
}

$out->close;