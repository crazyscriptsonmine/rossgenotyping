#!/usr/bin/perl
use strict;
use Statistics::R;

#plot the manhanttan plot of the ZHeterozygosity and the distribution
my $usage = "
==> To use '$0'
\t Plot the manhanttan plot of the ZHeterozygosity and the distribution.
Files needed...
\t<name of output> [required]
\t<ZHscore corrected ZH file> [required]
\t<original ZH file> [optional]

";

@ARGV >=2 or die $usage;
#picture
my $picture = "ZH-$ARGV[0]";
my $picture2 = "plot-$ARGV[0]";
$picture =~ s/\..+$/\.png/g;
$picture2 =~ s/\..+$/\.png/g;

my $path = $ENV{'PWD'};
my $R_code = <<"RCODE";
setwd("$path");
library(ggplot2);
library(ggrepel)
round2 = function(x, n) {
  posneg = sign(x)
  z = abs(x)*10^n
  z = z + 0.5
  z = trunc(z)
  z = z/10^n
  z*posneg
}
png(filename="$picture", width=960, height=480);
info = read.table("$ARGV[1]", header=T)
info\$CHROM <- factor(info\$CHROM, levels=unique(as.character(info\$CHROM)) )
vals <- rep(c(1,2,3,4,5,6),round2((length(info\$CHROM)/6),0))
p <- ggplot(data = info, aes(x = No, y = ZHeterozygosity, color=CHROM, label=GENE)) +
	scale_colour_manual(values = vals) + ylim(-8,0) +
  geom_point(stat = "identity", size=0.5) + labs(x = "Chromosome", y=expression(ZH[ W]))
p = p + geom_hline(yintercept=-4, color="black", linetype="dashed")
p + 
  theme_classic() + 
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        panel.spacing = unit(0, "lines")) +
  theme(legend.position="none") +
  scale_x_continuous(expand = c(0, 0)) +
  geom_text_repel(aes(label=ifelse(Verdict>=1,as.character(GENE),'')),size=3)
dev.off()
RCODE
if ($ARGV[2]){
	$R_code .= <<"RCODE";
png(filename="$picture2", width=480, height=480);
info = read.table("$ARGV[2]", header=T)
temp <- paste("mu == ", 0)
other <- paste("sigma == ", 1)
h <- ggplot(info,aes(x = ZHeterozygosity)) + 
  theme_classic() + 
  theme(legend.position="none") +
  geom_histogram(binwidth = .5,aes(fill =..count..)) +
  scale_fill_gradient("", low = "darkgrey", high = "navy") +
  labs(x=expression(ZH[ W]), y = "frequency")
h
dev.off()
RCODE
}
my $R = Statistics::R->new();
$R->startR;
$R->send($R_code);
$R->stopR();
	
