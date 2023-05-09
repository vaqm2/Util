#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $keys = {};

my $fh = IO::File->new("$ARGV[0]");

while(my $line = $fh->getline) {
    chomp($line);
    if($line =~ /^ID1/) {
        next;
    }
    else {
        my ($id1, $id2, $rho) = split(/\s+/, $line);
        my $key = $id1."_".$id2;
        $keys->{$key}->{rho} = $rho;
    }
}

$fh->close;

print "PyKin\tKinship2\n";

$fh = IO::File->new("$ARGV[1]");

while(my $line = $fh->getline) {
    chomp($line);
    my ($id1, $id2, $rho) = split(/\s+/, $line);
    my $key = $id1."_".$id2;

    if(exists $keys->{$key}) {
        print $rho."\t";
        print $keys->{$key}->{rho}."\n";
    }
}

$fh->close;