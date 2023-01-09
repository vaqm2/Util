#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new($ARGV[0]) || die "Cannot open file: $ARGV[0]!\n";

while(my $line = $fh->getline) {
    chomp($line);
    my $alt_name = $line;
    $line =~ s/\..*$//;
    $alt_name =~ s/\..*$//;
    $alt_name =~ s/^ \D+2015\D+ //x;
    $alt_name = "iPSYCH2015_".$alt_name;

    `mv $line.z $alt_name.z`;
    `mv $line.bgen $alt_name.bgen`;
    `mv $file.rsids.txt $alt_name.rsids.txt`;
    `mv $file.bgen.bgi $alt_name.bgen.bgi`;
}

$fh->close;