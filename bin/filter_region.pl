#!/usr/bin/perl
open(IN,"$ARGV[0]") or die "can't open $ARGV[0],$!";
open(OUT1,">$ARGV[1]") or die "can't write $ARGV[1],$!";
open(OUT2,">$ARGV[2]") or die "can't write $ARGV[2],$!";
@in=<IN>;
foreach(@in){
	chomp;
	@parts=split(" ",$_);
	$id="$parts[1] $parts[2] $parts[5] $parts[6]";
	push @{$id},$parts[3];
	push @{$id},$parts[4];
	$ids{$id}="";
}
foreach $id(keys %ids){
	@locis = sort { $a <=> $b } @{$id};
	$begin=shift @locis;
	$end=pop @locis;
	@lists=split(" ",$id);
	print OUT1 "$lists[0] $lists[1] $begin $end\n";
	@{$id}=();
}
%ids=();
foreach(@in){
	chomp;
	@parts=split(" ",$_);
	$id="$parts[1] $parts[2] $parts[5] $parts[6]";
	push @{$id},$parts[7];
	push @{$id},$parts[8];
	$ids{$id}="";
}
foreach $id(keys %ids){
	@locis = sort { $a <=> $b } @{$id};
	$begin=shift @locis;
	$end=pop @locis;
	@lists=split(" ",$id);
	print OUT2 "$lists[2] $lists[3] $begin $end\n";
	@{$id}=();
}
close IN;
close OUT1;
close OUT2;
