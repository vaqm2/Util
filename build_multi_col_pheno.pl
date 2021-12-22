#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fh = IO::File->new("$ARGV[0]") || die "ERROR: Cannot open file: $ARGV[0]"."!!\n";
my $pheno = {};
my @phenotypes;

while(my $line = $fh->getline) {
    chomp($line);
    my ($path, $phenotype) = split(/\s+/, $line);
    push(@phenotypes, $phenotype);

    my $nh = IO::File->new("$path") || die "ERROR: Cannot open pheno file: $path"."!!\n";

    while(my $nh_line = $nh->getline) {
        chomp($nh_line);

        if($nh_line =~ /^FID/i) {
            next;
        }
        else {
            my @nh_contents = split(/\s+/, $line);
            my $iid = $nh_contents[1];
            my $status = $nh_contents[2];
            $pheno->{$iid}->{$phenotype} = $status;
        }
    }

    $nh->close;
}

$fh->close;

@phenotypes = sort @phenotypes;
print "FID"." ";
print "IID";

for my $index(0..$#phenotypes) {
    print " ";
    print $phenotypes[$index];
}

print "\n";

for my $index(sort keys %$pheno) {    
    print $index."_ _";
    print $index;

    for my $idx2(0..$#phenotypes) {
        print " ";
        if(exists $pheno->{$index}->{$phenotypes[$idx2]}) {
            print $pheno->{$index}->{$phenotypes[$idx2]};
        }
        else {
            print "0";
        }
    }

    print "\n";
}