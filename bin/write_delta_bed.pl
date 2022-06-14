#!/usr/bin/perl
$delta="longest.delta.txt";
$out_bed=$ARGV[0];
open(IN,"$delta")or die"$!";
open(OUT,">$out_bed")or die"$!";
while(<IN>){
	if(/>(.*?):(.*?)-.*?\(.\) (.*?):.*/){
		$chr=$1;
		$begin=$2;
		$contig=$3;
	}else{
		/(.*?) (.*?) .*/;
		$match_b=$begin+$1;
		$match_e=$begin+$2;
		print OUT "$chr\t$match_b\t$match_e\t$contig\n";
	}
}
close IN;
close OUT;
