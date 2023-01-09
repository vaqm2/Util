#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new($ARGV[0]) || die "Cannot open file: $ARGV[0]!\n";

while(my $line = $fh->getline) {
    chomp($line);
    my $alt_name = $line;
    $alt_name =~ s/\..*$//;
    $alt_name =~ s/^ \D+2015\D+ //x;
    $alt_name = "iPSYCH2015_".$alt_name.".z";

    print $line." ".$alt_name."\n";
}

$fh->close;