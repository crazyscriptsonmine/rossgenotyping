#!/usr/bin/perl
#my @foldercontent = split("\n", find $file2consider);
use Data::Dumper qw(Dumper);

#opendir (DIR, $ARGV[0]);
@ARGV == 1 || die "No input folder specified";
$folder = $ARGV[0];
my @foldercontent = split("\n", `find $folder`);
#my @reads = readdir(DIR);
my (%ALL, %name);
foreach my $file (@foldercontent) {
	if ($file =~ /fastqc.*\.txt$/) { print "$file\n";
#foreach my $file (@reads) {
#	unless ($file =~ /\./) {
#		$file=~ /(.+)\.txt/;
#		$out = $1;
#		$fast = ls $ARGV[0]/$file/fastqc/*txt -1;
#		@fastqc = split (/\n/, $fast);
#		foreach my $line (@fastqc) {
		$file=~ /fastqc\/(\d.+).*\.txt$/;
                $out = $1;
		open(IN, $file);
		while (<IN>){
	  		chomp;
	  		@all = split /\t/;
	  		$name{$out} = 1;
			$ALL{$all[1]}{$out} = $all[0];
		}
	}
}

$outer = $ARGV[0]."-fastqcsummary.txt";
open(OUT,">", $outer) or die "output failed\n";
print OUT "\t"; foreach $key (sort keys %name) { print OUT "$key\t"; } print OUT "\n";
foreach $key (sort keys %ALL){
	print OUT "$key\t";
	foreach $okey (sort keys %name) { print OUT "$ALL{$key}{$okey}\t"; } print OUT "\n";
}

print "Stored in $outer\n";
#print Data::Dumper->Dump( [ \%ALL ], [ qw(*ALL) ] );;
