#!/usr/bin/perl

open (IN, "<", $ARGV[0]);
$trans = 0; 
$tranv = 0;
$ref = 2;
$alt =3;

while (<IN>) {
	if (/^chr/) { 
	@a = split("\t", $_);
if (($a[$ref] eq A && $a[$alt] eq G) || ($a[$ref] eq C && $a[$alt] eq T) || ($a[$ref] eq G && $a[$alt] eq A) || ($a[$ref] eq T && $a[$alt] eq C)){$trans++; } #print "yes\t$a[$ref]\t$a[$alt]\n";} 
 else {$tranv++; } #print "no\t$a[$ref]\t$a[$alt]\n";} 

$SNPALT{$a[$ref]}{$a[$alt]}++;
}
}print "$trans\n$tranv\n";
close IN;
print $trans/$tranv,"\n\n";

foreach $aa (keys %SNPALT){
foreach $bb (keys %{$SNPALT{$aa}}){
print "$aa>$bb\t$SNPALT{$aa}{$bb}\n"
}
}
