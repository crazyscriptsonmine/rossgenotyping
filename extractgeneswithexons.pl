#!/usr/bin/perl
use strict;
use IO::File;
use Pod::Usage;
use Getopt::Long;
use POSIX qw(ceil);
use Sort::Key::Natural qw(natsort);
use Statistics::R;
use Data::Dumper;

##### Usage Documentation
my $usage="
=> Arguments needed for '$0'
Extract the exonic annotation providing the original final merge file and other details below
\tfinal merge file
\tgene
\tchr
\tstart
\tstop
\toutput file name
\theterozygosity
\tZ-transformed heterozygosity

Copyright: 2017 MOA
Author: Modupeore Adetunji.
Institution: University of Delaware
";
##### Options of usage

@ARGV == 8 or die "Invalid options\n $usage";

####Logs

##### Global variables

my ($file, $gene, $chr, $start, $stop, $output, $het, $zh) = @ARGV;
my @genes = split(',', $gene);

##### User variables

my (@newvalues, %GENE);

##### Code
#getting the values
foreach my $ngene (@genes){
	my $values = `grep $chr $file | grep $ngene`;
	my @alvalues = split("\n", $values);

#reading the input
	foreach (@alvalues) {
		if (/synony/) {
			push @newvalues, $_;
		} elsif (/stop/) {
			push @newvalues, $_;
		} elsif (/splic/) {
			push @newvalues, $_;
		}
	}

	foreach (@newvalues){
		my @cols = split(/\t/);
		if ($cols[4] eq $ngene){ #print "@cols $cols[4]\n";
			if ($cols[1] >= $start && $cols[1] <= $stop) { #selecting only genes in that specified region
				push (@{$GENE{$cols[4]}}, $cols[5]);
			}
		} else {
			print "$cols[4] & $ngene are different\n";
		}
	}
	open (OUT, ">>$output");
	foreach my $key (keys %GENE){
		my %vres = map {$_ => 1} @{$GENE{$key}};
		print OUT "$chr\t$start\t$stop\t$key\t";
		my $finalkey = '';
		foreach my $okey (sort keys %vres){
			$finalkey .= "$okey,"
		}
		chop $finalkey;
		print OUT "$finalkey\t$het\t$zh\n";
#my @vres = @{GENEprint "$_,"\t", {$GENE{$_}},"\n";
	}
	close (OUT);
}
