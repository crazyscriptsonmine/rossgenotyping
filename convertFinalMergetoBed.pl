#!/usr/bin/perl
#Code for changing the genes to the exon
$usage = "Syntax for $0\n\tperl $0 <final-merge.table.txt> <output-filename>\n";
@ARGV == 2  || die $usage;
open(IN, "<",$ARGV[0]);
open(OUT, ">", $ARGV[1]);
while (<IN>) {
	($chrom, $position, $ref, $alt, $gene, $annotation, $af, $others) = split (/\t/, $_, 7);
	if ($af >= 0.99 || $af <= 0.01) { #working on Allele freq
		$score = 800;
	} else {
		$score = 100;
		if ($af > 0.01 && $af < 0.99) {
		$color = "0,0,0";
#varying the colors for the individual region
#		if ($af > 0.01 && $af <= 0.2 ) {
#			$color = "171,171,171"; #red
#		} elsif ($af > 0.2 && $af <= 0.5 ) {
#			$color = "93,93,93"; #pink
#		} elsif ($af > 0.5 && $af <= 0.7 ) {
#			$color = "255,255,255"; #yellow
#		} elsif ($af > 0.7 && $af < 0.99 ) {
#			$color = "101,101,101";
		} else {
			die "Died at $_";
		}
	}
	if ($annotation =~ /syn/ || $annotation =~ /stop/ || $annotation =~ /splic/) { #working on location
		$color = "0,255,0"; #green
	}
	print OUT $chrom,"\t",$position,"\t",$position+1,"\t",$gene,"(",$ref,"/",$alt,")\t",$score,"\t+\t",$position, "\t", $position+1,"\t", $color,"\n";
}
