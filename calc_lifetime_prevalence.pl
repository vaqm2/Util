#!/usr/bin/perl

use strict;
use warnings;
use IO::File;

my $at_risk;
my $prev_dx = "";
my $prev_gender = "";
my $cumulative_risk;

my $fh = IO::File->new("$ARGV[0]");

while(my $line = $fh->getline)
{
    chomp($line);

    if($line =~ /disorder/)
    {
        next;
    }

    my @lineContents      = split(/\,/, $line);
    my $disorder          = $lineContents[0];
    my $gender            = $lineContents[1];
    my $age_start         = $lineContents[2];
    my $age_end           = $lineContents[3];
    my $duration          = $age_end - $age_start + 1;
    my $incidence_rate    = $lineContents[4];

    if($disorder ne $prev_dx || $gender ne $prev_gender) {
        $at_risk = 10000;
        $cumulative_risk = 0;
    }

    my $cases_in_interval = $incidence_rate * $duration;
    my $risk              = $cases_in_interval/$at_risk;
    my $cumulative_risk  += $risk;

    print $disorder." ";
    print $gender." ";
    print $age_start." ";
    print $age_end." ";
    print $incidence_rate." ";
    print $at_risk." ";
    print $cases_in_interval." ";
    print $risk." ";
    print $cumulative_risk."\n";

    $prev_dx     = $disorder;
    $prev_gender = $gender;
    $at_risk     = $at_risk - $cases_in_interval;
}