#!/usr/bin/perl
$id=$ARGV[0];
$type=$ARGV[1];
$txt=$ARGV[2];
$fasta=$ARGV[3];
$samtools=$ARGV[4];
open(IN,"chrlen.txt") or die "can't open chrlen.txt,$!";
while(<IN>){
	chomp;
	@parts=split("\t",$_);
	$chrlen{$parts[0]}=$parts[1];
}
close IN;
open(TXT,"$txt") or die"can't open,$!";
while(<TXT>){
	chomp;
	@lines=split(" ",$_);
	if ($type eq 'contig'){
		if($lines[2]==0){
			$begin=0;
			$end=200;
		}else{
			$end=$lines[3];
			$begin=$end-199;
		}
	}
	if ($type eq 'chr'){
		$begin=$lines[2]-500;
		$end=$lines[3]+500;
		if($begin<0){
			$begin=0;
		}
		if($end>$chrlen{$lines[0]}){
			$end=$chrlen{$lines[0]};
		}
	}
	$region="$lines[0]:$begin-$end";
	`$samtools faidx -n 80 --mark-strand sign $fasta $region >> $id.$type.fasta`;
}
close TXT;
