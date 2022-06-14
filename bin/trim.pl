#!/usr/bin/perl
$fasta=$ARGV[0];
$delta=$ARGV[1];
$out_fasta=$ARGV[2];
$samtools=$ARGV[3];
open(DELTA,"$delta")or die"$!";
open(FAS,"$fasta")or die "$!";
while(<FAS>){
	chomp;
	if (/^>/){
		$_=~ s/>//;
		push @ids,$_;
	}
}
while(<DELTA>){
	if(/^>/){
		/>(.*?):(.*?)-(.*?)\(.\) (.*?):(.*?)-(.*?)\(.\) .*/;
		$chr=$1;
		$chr_s=$2;
		$chr_e=$3;
		$contig=$4;
		$contig_s=$5;
		$conig_e=$6;
		foreach (@ids){
			if ($_=~ /$contig/){
				$id=$_;
			}
		}
	}else{
		/(.*?) (.*?) (.*?) (.*?) .*/;
		if($3>$4){$h_num=$3;$l_num=$4};
		if($3<$4){$h_num=$4;$l_num=$3};
		if($contig_s == 0){
			$end=$h_num+1;
			`$samtools faidx -n 80 $fasta $id:$end- >>$out_fasta`;
		}else{
			$end=$contig_s+$l_num-2;
			`$samtools faidx -n 80 $fasta $id:0-$end >>$out_fasta`;
		}
	}
}
close DELTA;
close FAS;
