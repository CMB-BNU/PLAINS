#!/usr/bin/perl
$fasta=$ARGV[0];
$out_delta=$ARGV[1];
$delta_path=$ARGV[2];
open(FAS,"$fasta")or die "$!";
open(OUT,">$out_delta")or die "$!";
$or=$/;
$/=">";
while(<FAS>){
	next if /^>$/;
	/(.*?)\n(.*)/s;
	my $id =$1;
	my $seq = "\U$2";
	$seq=~ s/\n//g;
	$seq=~ s/>//g;
	$seqs{$id}=$seq;
}
$/=$or;
close FAS;
foreach (keys %seqs){
	@parts=split(":",$_);
	$id=$parts[0];
	$contig=$parts[1];
	$/=">";
	open(IN,"$delta_path/$id.delta.f")or die "$!";
	while(<IN>){
		if(/$contig/){
			$_=~s/>//g;
			print OUT ">$_";
		}
	}
	close IN;
}
$/=$or;
close OUT;
