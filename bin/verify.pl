#!/usr/bin/perl
$nucmer=$ARGV[0];
@files=`ls`;
foreach (@files){
	chomp;
	next unless(/fasta/);
	@parts=split('fasta',$_);
	$hash{$parts[0]}="";
}
foreach (keys %hash){
	next if (/longest/);
	$longest="${_}longest.fasta";
	$all="${_}fasta";
	`$nucmer -p ${_}verify $longest $all`;
}
