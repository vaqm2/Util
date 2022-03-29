#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $usage = "\n\nUSAGE: perl $0 file_with_cm.map file_wo_cm.bim\n\n";

if(!$ARGV[0] || !$ARGV[1]) {
    print $usage;
    exit;
}

my $genetic_distance = {};
my $fh = IO::File->new("$ARGV[0]") || die "ERROR: Cannot open map file: $ARGV[0]!\n";

while(my $line = $fh->getline) {
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $chromosome = $lineContents[0];
    my $distance   = $lineContents[2];
    my $position   = $lineContents[3];
    my $key        = $chromosome."_".$position;
    $genetic_distance->{$key} = $distance;
}

$fh->close;

my $nh = IO::File->new("$ARGV[1]") || die "ERROR: Cannot open bim file: $ARGV[1]!\n";

while(my $line = $nh->getline) {
    chomp($line);
    my @lineContents = split(/\s+/, $line);
    my $chromosome   = $lineContents[0];
    my $position     = $lineContents[3];
    my $key          = $chromosome."_".$position;

    if(exists $genetic_distance->{$key}) {
        print $lineContents[0]." ";
        print $lineContents[1]." ";
        print $genetic_distance->{$key}." ";
        print $lineContents[3]." ";
        print $lineContents[4]." ";
        print $lineContents[5]."\n";
    }
    else {
        print "WARNING: No match found for: $line\n";
    }
}

$nh->close;