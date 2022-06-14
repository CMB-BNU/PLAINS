#!/usr/bin/perl
$delta=$ARGV[0];
$leftbed=$ARGV[1];
$rightbed=$ARGV[2];
$id=$ARGV[3];
open(IN,"$delta")or die"can't open $delta,$!";
open(OUT1,">$leftbed")or die"can't write $leftbed,$!";
open(OUT2,">$rightbed")or die"can't write $rightbed,$!";
while(<IN>){
	next if /data1/;
	next if /NUCMER/;
	if(/>(.*?):(.*?)-(.*?)\((.)\) (.*?):(.*)/){
		$chr=$1;
		$begin=$2;
		$end=$3;
		$strand=$4;
		$contig=$5;
	}else{
		/(.*?) (.*?) (.*?) (.*?) (.*)/;
		$match_begin=$1;
		$match_end=$2;
		$chrstart=$begin+$match_begin-1;
		$chrend=$begin+$match_end-1;
		if($3<=5 or $3>=196){
			print OUT1 "$chr\t$chrstart\t$chrend\t$id:$contig\t0\t$strand\n";	
		}elsif($4<=5 or $4>=196){
			print OUT2 "$chr\t$chrstart\t$chrend\t$id:$contig\t0\t$strand\n";	
		}
	}
}
close IN;
close OUT1;
close OUT2;
