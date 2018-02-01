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
\toutput file name

Copyright: 2017 MOA
Author: Modupeore Adetunji.
Institution: University of Delaware
";
##### Options of usage

@ARGV == 2 or die "Invalid options\n $usage";

####Logs

##### Global variables

my ($file, $output) = @ARGV;

##### User variables

my @newvalues;

##### Code
#reading the final merge file
open (IN, "<$file");
while(<IN>) {
	if (/synony/) {
		push @newvalues, $_;
        } elsif (/stop/) {
                push @newvalues, $_;
        } elsif (/splic/) {
                push @newvalues, $_;
        }
} close (IN);

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
