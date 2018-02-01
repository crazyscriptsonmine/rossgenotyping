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
\tinitial final merge file
\tZHresults file
\toutput file name

Copyright: 2017 MOA
Author: Modupeore Adetunji.
Institution: University of Delaware
";
##### Options of usage

@ARGV == 3 or die "Invalid options\n $usage";

####Logs

##### Global variables

my ($file, $ZHfile, $output ) = @ARGV;
open (IN, "<", $ZHfile);
open (OUT, ">$output");
print OUT "CHROM\tSTART\tEND\tGENE\tFUNCTION\tSNPCOUNT\tHeterozygosity\tZHeterozygosity\n";
close (OUT);

while (<IN>) {
	chomp;
	my ($chr, $start, $stop, $gene, $func, $snp, $het, $zh) = split /\t/;
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
		} #end foreach values of the parse
		foreach (@newvalues){
			my @cols = split(/\t/);
			if ($cols[4] eq $ngene){ #print "@cols $cols[4]\n";
				if ($cols[1] >= $start && $cols[1] <= $stop) { #selecting only genes in that specified region
					push (@{$GENE{$cols[4]}}, $cols[5]);
				}
			} else {
				print "$cols[4] & $ngene are different\n";
			}
		} #end foreach for @newvalues for accepted values
		open (OUT, ">>$output");
		foreach my $key (keys %GENE){
			my %vres = map {$_ => 1} @{$GENE{$key}};
			print OUT "$chr\t$start\t$stop\t$key\t";
			my $finalkey = '';
			foreach my $okey (sort keys %vres){
				$finalkey .= "$okey,"
			}
			chop $finalkey;
			print OUT "$finalkey\t$snp\t$het\t$zh\n";
#my @vres = @{GENEprint "$_,"\t", {$GENE{$_}},"\n";
		}
		close (OUT);
		undef %GENE;
	} #end foreach @gene
}

