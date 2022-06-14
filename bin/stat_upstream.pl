#!/usr/bin/perl
#$bed="new_loci.txt";
$bed=$ARGV[0];
#$gff="/data/home/chenyd/reference/JMA_sort.gff";
$gff=$ARGV[1];
$out=$ARGV[2];
open(BED,"$bed") or die "can't open $bed,$!";
open(GFF,"$gff") or die "can't open $gff,$!";
open(OUT,">$out") or die "can't write $out,$!";
@gff=<GFF>;
while(<BED>){
	chomp;
	%genes=();
	@parts=split("\t",$_);
#	$chr=$parts[0];
#	$begin=$parts[1]-1;
#	$end=$parts[2]-1;
#	$len=$end-$begin+1;
#	$id=$parts[3];
	$chr=$parts[2];
	$begin=$parts[3];
	$end=$parts[3];
	$id=$parts[0]."\t".$parts[1];
	print OUT "$chr\t$id\t$begin\t$end\t$len\t";
	foreach(@gff){
		if(/^$chr\t/){
			@lines=split("\t",$_);
			if ($lines[2] eq "gene"){
				$begin2=$lines[3];
				$end2=$lines[4];
				if($begin<=$begin2-5000 or $begin>=$begin2){
					next;
				}else{
					$lines[8]=~ /Name=(.*?)\n/;
					$genes{$1}="";
				}
			}
		}
	}
	$geneid="";
	if(%genes){
		foreach $key(keys %genes){
			$geneid.="$key,";
		}
		chop $geneid;
	}else{
		$geneid="NA";
	}
	print OUT "$geneid\n";	
}
close BED;
close GFF;
close OUT;
