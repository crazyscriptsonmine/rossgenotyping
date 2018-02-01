#!/usr/bin/perl
use strict;
my $i = 4;
my %index;
use Data::Dumper;
my %finalindex;
use Sort::Key::Natural qw(natsort);
use Getopt::Long;
use Pod::Usage;
my  ($one, $two, $three, $four);
GetOptions ("one" => \$one,"two"=> \$two, "three" => \$three, "four" => \$four);

my $usage = "
'$0 <option> <input file>'
-one if to extract Passes for tissues [or]
-two if to extract exonic regions
";
die "Select only one option\n $usage" if ($one && $two);
@ARGV == 1 or die "Error $usage";
if ($one) {
open (IN, $ARGV[0]) or die "Can't open input file\n";
while (<IN>){
	if (/^chr/){
		chomp;
		my @details = split(/\t/);
		foreach my $key (keys %index){
			if ($details[$key] eq "PASS"){
				if (exists $finalindex{$details[0]}{$details[1]}){
					$finalindex{$details[0]}{$details[1]} = "$finalindex{$details[0]}{$details[1]},$index{$key}";
				} else {
					$finalindex{$details[0]}{$details[1]} = $index{$key};
				}
			}
		}
	} elsif (/abdo/) {
		my @all = grep /\S+/, split(/\t/);
		foreach (@all){
			my $tissue = (split(/\./, $_))[0];
			$index{$i} = $tissue;
			$i += 4;
		}
		print Data::Dumper->Dump( [ \%index ], [ qw(*GENE) ] );
	}
}
close (IN);
print "Done with input file\n";
open (OUT, ">merge-tissues.txt");
foreach my $aa (natsort keys %finalindex){
	foreach my $bb (sort {$a <=> $b} keys %{$finalindex{$aa}}){
		print OUT "$aa\t$bb\t$finalindex{$aa}{$bb}\n";
	}
} #end while
close (OUT);
}
if ($two){
open (IN, $ARGV[0]) or die "Can't open input file\n";
open (OUT, ">pseudo-output.txt");
while (<IN>){
	if (/^chr/){
		my $detail = (split(/\t/))[5];
		if (($detail =~ /stop/) ||($detail =~ /unknown/) || ($detail =~ /syn/) || ($detail =~ /splic/) || ($detail =~ /^exon/) ||($detail =~ /stop/)) {
			print OUT $_;
		}
	} else {print OUT $_;}
} #end while
close OUT; close IN;
}
if ($three){
	#extract genes for a file
open (IN, $ARGV[0]) or die "Can't open input file\n";
my @odadets;
my $j = 0;
while (<IN>){
	if (/^chr/){
		push @odadets, (split(/\t/))[4];
	}
} #end while
close IN;
my %oda = map {$_ => 1} @odadets;
foreach (sort keys %oda){ $j++; print "$_\n";}
print "\n";
print "$j\n";
}
if ($four){
	#extract genes for impt-file
open (IN, $ARGV[0]) or die "Can't open input file\n";
my %real;
my $no = 0;
while (<IN>){
	if (/^chr/){
		chomp;
		my @details = split(/\t/);
		$details[0] =~ /chr(.*)$/;
		if (exists $finalindex{$details[0]}{$details[7]}){
			unless ($finalindex{$details[0]}{$details[7]} == "$1\t$details[3]\t$details[4]\t$details[5]\t$details[6]\t$details[7]\n"){
				die "Error\n";
			}
		} else {
			$no++;
			$real{$no} = "$no\t$1\t$details[1]\t$details[3]\t$details[4]\t$details[5]\t$details[6]\t$details[7]\n";
			$finalindex{$details[0]}{$details[7]} = "$1\t$details[3]\t$details[4]\t$details[5]\t$details[6]\t$details[7]\n";
		}
	}
}
close (IN);
print "Done with input file\n";
open (OUT, ">convertimpttoRcode.txt");
print OUT "No\tCHROM\tSTART\tGENE\tFUNC\tCOUNT\tHT\tZHeterozygosity\n";
foreach my $aa (sort {$a <=> $b} keys %real){
	print OUT $real{$aa};
}
close (OUT);
}