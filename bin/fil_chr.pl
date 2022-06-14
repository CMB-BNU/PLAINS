#!/usr/bin/perl
open(IN,"$ARGV[0]")or die"can't open,$ARGV[0],$!";
@in=<IN>;
foreach(@in){
	@parts=split(" ",$_);
	$contig=$parts[1];
	$chr=$parts[5];
	${$contig}{$chr}+=1;
	push @contigid,$contig;	
}
foreach(@contigid){
	$contig=$_;
	foreach $chr(keys %{$contig}){
		$total_num+=${$contig}{$chr};
	}
	foreach $chr(keys %{$contig}){
		$per=${$contig}{$chr}/$total_num;
		if ($per>=0.95){
			$f="success";
		}
	}
	if ($f eq "success"){
		push @filter,$contig;
	}
	$f="";
	$total_num=0;
}
open(OUT,">$ARGV[1]")or die"can't write ,$!";
foreach (@in){
	$line=$_;
	foreach(@filter){
		if ($line=~/$_/){
			$p="success";
		}
	}
	if ($p eq "success"){
		print OUT $line;
	}
	$p="";
}
close IN;
close OUT;
