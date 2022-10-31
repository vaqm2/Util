#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $dict = {};

my $fh = IO::File->new($ARGV[0]) || die "ERROR: Cannot open assoc file: $ARGV[0]!!\n";

while(my $line = $fh->getline)
{
    chomp($line);
    $line =~ s/^\s+//;

    if($line =~ /^CHR/)
    {
        print $line."\n";
        next;
    }

    my @lineContents = split(/\s+/, $line);
    my $chr          = $lineContents[0];
    my $position     = $lineContents[1];
    my $a1           = $lineContents[3];
    my $a2           = $lineContents[4];
    my $key          = $chr."_".$position."_".$a1."_".$a2;

    if(exists $dict->{$key})
    {
        next;
    }

    print $line."\n";
    $dict->{$key} = 1;
}

close(IN);