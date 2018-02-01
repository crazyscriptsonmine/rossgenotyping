#!/usr/bin/perl
use strict;
my ($i, $ZHnew);
#plot the manhanttan plot of the ZHeterozygosity and the distribution
my $usage = "
==> To use '$0'
\t Extract exonic regions (point substitutions, splicing and stop mutations);
Files needed...
\t<ZHresult file> [required]
\t<name of outputfile> [required]

";

@ARGV ==2 or die $usage;
open(IN, "<",$ARGV[0]);
open (OUT, ">", $ARGV[1]);
open (OUT2, ">", "forR-".$ARGV[1]);
open (OUT3, ">", "impt-".$ARGV[1]);
print OUT "CHROM\tSTART\tEND\tGENE\tFUNCTION\tSNPCOUNT\tHeterozygosity\tZHeterozygosity\n";
print OUT2 "No\tCHROM\tSTART\tEND\tGENE\tFUNCTION\tSNPCOUNT\tHeterozygosity\tZHeterozygosity\n";
print OUT3 "CHROM\tSTART\tEND\tGENE\tFUNCTION\tSNPCOUNT\tHeterozygosity\tZHeterozygosity\n";
$i = 0;
while (<IN>){
	chomp;
	my ($CHR, $START, $END, $GENE, $FUNCTION, $SNPcount, $Heterozygosity, $ZHeterozygosity) = split /\t/;
	$CHR =~ /^chr(.*)$/;
	my $CHROM = $1;
	if ($ZHeterozygosity > 0) { $ZHnew = $ZHeterozygosity*-1; } else { $ZHnew = $ZHeterozygosity; }
	if (($FUNCTION =~ /syn/) ||  ($FUNCTION =~ /stop/) || ($FUNCTION =~ /splic/)) {
		$i++; print OUT "$CHR\t$START\t$END\t$GENE\t$FUNCTION\t$SNPcount\t$Heterozygosity\t$ZHeterozygosity\n";
		print OUT2 "$i\t$CHROM\t$START\t$END\t$GENE\t$FUNCTION\t$SNPcount\t$Heterozygosity\t$ZHnew\n";
		if ($ZHeterozygosity <= -4 ) {
			print OUT3 "$CHR\t$START\t$END\t$GENE\t$FUNCTION\t$SNPcount\t$Heterozygosity\t$ZHeterozygosity\n";
		}
	}
} close (IN);
close (OUT);
