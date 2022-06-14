#!/usr/bin/perl
$delta=$ARGV[0];
$fil_file=$ARGV[1];
open(DELTA,"$delta")or die"can't open $delta,$!";
open(OUT,">$fil_file")or die "can't write $fil_file,$!";
@deltas=<DELTA>;
foreach(@deltas){
	if(/data1/){print OUT;next;}
	if(/^NUCMER/){print OUT;next;}
	next if (/^0\n$/);
	if(/^>/){
		/>(.*?) (.*?) (.*)/;
		$id=$2;
	}else{
		next if /^0\n$/;
		$hash{$id}++;
	}
}
foreach $id(keys %hash){
	if ($hash{$id}==1){
		foreach(@deltas){
			next if (/data1/);
			next if (/NUCMER/);
			if(/\Q$id\E/){print OUT;$i=1;next;}
			if($i==1){print OUT;$i=0;}
		}
	}
}
close DELTA;
close OUT;
