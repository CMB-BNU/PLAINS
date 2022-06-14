#!/usr/bin/perl
$delta=$ARGV[0];
$fil_file=$ARGV[1];
open(DELTA,"$delta")or die"can't open $delta,$!";
open(OUT,">$fil_file")or die "can't write $fil_file,$!";
while(<DELTA>){
	if(/data1/){print OUT;next;}
	if(/^NUCMER/){print OUT;next;}
	next if (/^0\n$/);
	if(/^>/){
		$match=$_;
		/>.*?:.* .*:(.*?)-.*/;
		$loci=$1;
	}else{
		/(.*?) (.*?) (.*?) (.*?) (.*?)/;
		if(($loci==0 and $3<=5) or ($loci!=0 and $3>=196) or ($loci==0 and $4<=5) or ($loci!=0 and $4>=196)){
			$hash{$match}="";
			push @{$match},$_;
		}
	}
	
}
foreach $match(keys %hash){
	next if ($match eq "");
	print OUT $match;
	foreach(@{$match}){
		next if ($_ eq "");
		print OUT $_;
	}
}
close DELTA;
close OUT;
