#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new($ARGV[0]);

while(my $line = $fh->getline) {
    chomp($line);
    my ($chr, $start, $end) = split(/\s+/, $line);

    while($start < $end) {
        print $chr.":".$start."-";
        if($end - $start > 3000000) {
            $start = $start + 3000000;
        }
        else {
            $start = $end;
        }
        print $start."\n";
    }
}

$fh->close;