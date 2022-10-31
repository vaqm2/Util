#!/usr/bin/env perl

use strict;
use warnings;
use IO::File;

my $fof  = IO::File->new($ARGV[0]) || die "Cannot open file of files: $ARGV[0]"."!!\n";
my $snps = {};
my @queue;

while(my $assoc = $fof->getline) {
    chomp($assoc);
    my ($assoc_num, $assoc_file) = split(/\s+/, $assoc);
    push(@queue, $assoc_num);
    
    my $fh = IO::File->new($assoc_file) || die "Cannot open association file: $assoc"."!!\n";

    while(my $line = $assoc_file->getline) {
        chomp($line);
        if($line =~ /^CHR/) {
            next;
            if($assoc_num == 1) {
                print "CHR"."\t";
                print "BP"."\t";
                print "SNP"."\t";
                print "A1"."\t";
                print "A2"."\t";
                print "FREQ"."\t";
            }
            else {
                print "BETA_".$assoc_num."\t";
                print "SE_".$assoc_num."\t";
                print "P_".$assoc_num."\n";
            }
        }
        else {
            my @lineContents = split(/\s+/, $line);
            my $chromosome   = $lineContents[0];
            my $position     = $lineContents[1];
            my $snp          = $lineContents[2];
            my $a1           = $lineContents[3];
            my $a2           = $lineContents[4];
            my $freq         = $lineContents[5];
            my $beta         = $lineContents[6];
            my $se           = $lineContents[7];
            my $p            = $lineContents[8];
            my $key          = $chromosome."_".$position."_".$a1."_".$a2;

            if($freq < 0.01) {
                next;
            }
            else {
                if(!exists $snps->{$key}) {
                    $snps->{$key}->{chrom} = $chromosome;
                    $snps->{$key}->{bp}    = $position;
                    $snps->{$key}->{snp}   = $snp;
                    $snps->{$key}->{a1}    = $a1;
                    $snps->{$key}->{a2}    = $a2;
                }
                $snps->{$key}->{$assoc_num}->{beta} = $beta;
                $snps->{$key}->{$assoc_num}->{se}   = $se;
                $snps->{$key}->{$assoc_num}->{p}    = $p;
            }
        }
    }

    $fh->close;
}

$fof->close;

for my $index(sort keys %$snps) {
    print $snps->{$index}->{chrom}."\t";
    print $snps->{$index}->{bp}."\t";
    print $snps->{$index}->{snp}."\t";
    print $snps->{$index}->{a1}."\t";
    print $snps->{$index}->{a2};

    for my $num(0..$#queue) {
        if(eixsts $snps->{$index}->{$queue[$num]}) {
            print "\t".$snps->{$index}->{$queue[$num]}->{beta};
            print "\t".$snps->{$index}->{$queue[$num]}->{se};
            print "\t".$snps->{$index}->{$queue[$num]}->{p};
        }
        else {
            print "\tNA\tNA\tNA";
        }
    }

    print "\n";
}