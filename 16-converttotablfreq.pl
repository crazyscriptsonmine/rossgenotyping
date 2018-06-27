#!/usr/bin/perl
use strict;
use Pod::Usage;
use Getopt::Long;
use List::MoreUtils 'pairwise';
# convert to table and estimate AF

#- - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
print "\t**Estimate AF and convert to table based on columns specified excluding the FORMAT fields**\n";
my $usage = "
To use : '$0'
\t-V|v VCF file.
\t-F|f columns (multiple columns are separated by comma).
\t-o|O output file name.
";
my ($variant, $columns, $output);
GetOptions('V|v=s'=>\$variant, 'F|f=s'=>\$columns , 'O|o=s'=>\$output) or die $usage;
die "Incomplete Arguments!\n$usage" if(!$variant || !$columns || !$output);

# - - - - - G L O B A L V A R I A B L E S - - - - - - - - -

my (%header, %info, %format, %filter, @headerline, $line, $verdict, @sumAC);
open (OUT,">", $output);
my $note;

# - - - - - M A I N - - - - - - - - - - - - - - - - - - -

#print out header
print OUT "CHROM\tPOS\t"; #default output
#Parse columns specified
$columns =~ s/\s+|\s+//g;
my @filter = split (",", $columns); #specific columns requested
my $i = 0; foreach (@filter){ $filter{$i++} = uc($_); unless ( ($_ =~ /CHROM/i) || ($_ =~ /POS/i)){ print OUT uc($_),"\t"; } } #making sure CHROM, POS isn't printed twice
print OUT "new-AC\tnew-AF\tnote\n"; #new AC and AF
#variant file
open (COMMON, $variant) or die "Can't open '$variant'\n$usage";
while (<COMMON>){ #reading variant file
	chomp;
	if (/^chr.*/) {
		undef $verdict;
		my ($newAC, $newAF) = (0,0);
		my @newAC;
		$line = $_;
    my @commonline = split (/\t/, $line); #each variant
		
		#extracting all the columns into a hash key based on the info column.
		my $selectfilter = $commonline[$header{"INFO"}]; #split the info column
		my @info = split (/\;/, $selectfilter);
		undef %info; #clean the info hash
		foreach (@info) {
			my @theinfo = split("\=", $_, 2);
			$info{uc($theinfo[0])} = $theinfo[1]; #store info into dictionary
		}
		
		#estimating AF from FORMAT column
		my $selectformat = $commonline[$header{"FORMAT"}];
		my @format = split (/\:/, $selectformat); #geting the format order
		undef %format; #clean format hash
		foreach (0..$#format){ $format{$format[$_]} = $_; }
		if (exists $format{"AD"}) {
			my $cols = $header{"FORMAT"} + 1; #working on the Label
			foreach my $colloc ($cols..$#headerline) { #checking to see if there are multiple labels. (for merged VCF files)
				if ($commonline[$colloc] =~ /^\d/) {
					my $allAD = (split (/\:/,$commonline[$colloc]))[$format{"AD"}];
					if ($allAD =~ /^\d/) {
						my ($ADref, $ADalt) = split(",", $allAD,2); #perfect diploid cases
						if ($ADalt =~ /,/){ #if multiple alternate alleles
							#print $line,"\n";
							my @tmpAC = @newAC;
							my $sumAD = $ADref;
							$verdict = "yes";
							my @alts = split(/,/, $ADalt);
							foreach (@alts) { $sumAD +=$_; }
							
							#print "$ADalt\t@alts\t$sumAD\t@tmpAC\n";
							my @sumAC = map { sprintf("%.3f", ($_ / $sumAD)) } @alts;
							@newAC = pairwise { $a + $b } @tmpAC, @sumAC;
						} else {
							$verdict = "no";
							#print "$commonline[$colloc]\t$ADalt\t$ADref\n";
							if ($ADalt == 0 && $ADref == 0){ $newAC += 0 ; }
							else { $newAC += (sprintf ("%.3f", ($ADalt/($ADref+$ADalt)))); }
							if ($ADalt < 2) {$note .= "less than 2";} elsif ($ADalt < 3) {$note .= "less than 3";} else {$note .= "not";}
						}
					#} else {
					#	if($commonline[$header{"ALT"}] =~ /,/) {
					#		#die;
					#		my @tmpAC = @newAC;
					#		$verdict = "yes";
					#		my @alts = split(/,/, $commonline[$header{"ALT"}]);
					#		my $sumAC; foreach (@alts){push @sumAC, 1;}
					#		@newAC = pairwise { $a + $b } @tmpAC, @sumAC;
					#	} else {
					#		$verdict = "no";
					#		$newAC += 1;
					#	}
					} #end if AD info exist
				} #end if details exist in colloc
			} 
			if ($verdict eq "no") {
				#print "ADalt $sumADalt\tAD ",$sumAD,"\t","AC",$newAC,"\tAN ", $info{"AN"},"\n";
				$newAF = (sprintf ("%.3f", ($newAC/($info{"AN"}/2)))); #convert it to a haploid case, to estimate AF
			}elsif ($verdict eq "yes") {
				my @newAF = map { sprintf("%.3f", ($_ / ($info{"AN"}/2))) } @newAC;
				$newAC = join(",", @newAC);
				$newAF = join(",", @newAF);
			}
		} else {
			$newAC = "null";
			$newAF = "null";
		}
		#print out columns specified and the new file
		
		print OUT $commonline[$header{"#CHROM"}],"\t", $commonline[$header{"POS"}];
		foreach (sort {$a <=> $b} keys %filter){
			unless ( ($filter{$_} =~ /CHROM/) || ($filter{$_} =~ /POS/)){
				if (exists $header{$filter{$_}}){
					print OUT "\t$commonline[$header{$filter{$_}}]";
				} elsif (exists $info{$filter{$_}}){
					print OUT "\t$info{$filter{$_}}";
				} else { die "'$filter{$_}' does not exist in the variant file\n"; }
			}
		}
		if ($note =~ /not/) { undef $note; } else {if ($note =~ /3/) { $note = "less than 3"; } else {$note = "less than 2";} }
		if ($newAF < 0.1) { print OUT "\t$newAC\t$newAF\t$note\tremove\n"; }
		else { print OUT "\t$newAC\t$newAF\t$note\t\n"; } 
		undef $note;
	} elsif (/^#CH/) { #get the header column
		@headerline = split /\t/;
		foreach (0..$#headerline){ $header{$headerline[$_]} = $_; }	
	}
}
close COMMON;

