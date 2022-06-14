#!/usr/bin/perl
$read_path=$ARGV[0];
$config_path=$ARGV[1];
open(IN,"$ARGV[2]")or die "can't open $ARGV[2],$!";
$t=$ARGV[3];
while(<IN>){
	chomp;
	$id=$_;
	open (OUT,">$config_path/$id.config");
	print OUT "DATA\n";
	print OUT "PE= pe 300 50 $read_path/${id}_mateUnmapped_R1.fq $read_path/${id}_mateUnmapped_R2.fq\n";
	print OUT "PE= s1 300 50 $read_path/${id}_R1_mateUnmapped.fq\n";
	print OUT "PE= s2 300 50 $read_path/${id}_R2_mateUnmapped.fq\n";
	print OUT "END\n\n";
	print OUT "PARAMETERS\nGRAPH_KMER_SIZE=auto\nUSE_LINKING_MATES=1\nKMER_COUNT_THRESHOLD=1\nNUM_THREADS=${t}\nJF_SIZE=200000000\nDO_HOMOPOLYMER_TRIM=0\nEND";
	close OUT;
}
close IN;
