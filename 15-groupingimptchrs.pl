#!/usr/bin/perl
my ($count4, $count5, $count6) = (0,0,0);
open (IN, $ARGV[0]);
while (<IN>){
$all = (split("\t",$_))[-1];
if ($all <= -2){ $count4++; print $_; }
if ($all <= -5){ $count5++; } #print $_; }
if ($all <= -6){ $count6++; } #print $_; }
}

#print "$ARGV[0]\t$count4\t$count5\t$count6\n";
