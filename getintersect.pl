#!/usr/bin/perl
use strict; 
use File::Basename; 
#get the intersection of gatk merge

#- - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
print "\t**GET INTERSECT**\n";
my $usage = "
To use : '$0'
\tVCF file to get in the intersection.\n
";
@ARGV == 2 or die $usage;
my $out = $ARGV[1];
# - - - - - G L O B A L V A R I A B L E S - - - - - - - - -
my (%comparison, %commonfile, %inputfile, %GATKs); #, @new);
my $i = 0;
my ($line, $header);
my $base = `basename $ARGV[0]`; chomp $base;
#my $out = "intersect-".$base;
#.fileparse($ARGV[0], qr/\.[^.]*(\.vcf)?$/).".vcf";
open (OUT,">", $out);
# - - - - - M A I N - - - - - - - - - - - - - - - - - - -

open (COMMON, $ARGV[0]) or die "Can't open '$ARGV[0]'\n$usage";
while (<COMMON>){
	if (/^#/){
		print OUT $_;
	}
	elsif (/Intersection/){ $i++;
		print OUT $_;
	}
}

print "Total $i\n";
