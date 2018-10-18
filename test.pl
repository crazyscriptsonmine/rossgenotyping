my $usage = "
To use : '$0'
\tGET the KaKsratios on the table gene file and then plot using R.\n
\t\tusage\t:\t$0 forRfile.txt manipulatedconvertedgenes.txt finalkaks/scoreILL\n
\t\tresults will be printed as standard output.\n";
@ARGV == 3 or die $usage;

#for i in $(l -1 forR-ZHforR-default_hetero*); do echo $i; perl test.pl $i ~/workamodupe/rossgenotyping/manipulatedconvertedgenes.txt ~/workamodupe/finalKAKS/finalkaks/scoreILL > 1-$i; done

open(ONE,$ARGV[0]);

while (<ONE>){
	chomp;
	@line = split /\t/;
  	unless($line[4] =~ /\x3b/) {
  		if ($line[4] =~ /(^ENSGAL.*)\.\d$/) {
      			$name = $1;
			@fakeline = split('-_',`grep $name $ARGV[1]`);
			if (length($fakeline[2]) >1) { $newname = $fakeline[2] } else { $newname=$name; }
    		} else { $newname = $line[4]; }
  	} else {$newname = $line[4]; }
	
	@scoredetails = split("\t", `grep "^$newname" $ARGV[2] | head -n 1`);
	
	($average,$number,$counter)=(0,0,0);
	foreach my $score (2..4) {
		if ($scoredetails[$score] > 0){
			$counter++; 
			$number = $scoredetails[$score] + $average;
		}
	}
	if ($counter==0) { 
		$average = "NA"; 
		$verdict = "null";
	}
	else {
		$average = $number/$counter;
		if($average<0.99) { 
			$verdict = "negative";
		} elsif($average>1.01) {
			$verdict = "positive";
		} else { $verdict = "neutral"; }
	}
	print join("\t",@line[0..3]);
	print "\t$newname\t";
	print join("\t",@line[5..$#line]);
	print "\t$average\t$verdict\n";
}
				
  
