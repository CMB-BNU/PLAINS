#!/usr/bin/perl
$filename=$ARGV[0];
$cen=$ARGV[1];
open(FAS,"<$filename") or die "can't open $filename,$!";
my $or=$/;
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
open(TXT,"$cen") or die"can't open $cen,$!";
open(OUT,">$ARGV[2]")or die "can't write ,$!";
while(<TXT>){
	next if /readID/;
	@parts=split("\t",$_);
	$id=$parts[0];
	if ($parts[5]==0){
		print OUT ">$id\n";
		my $seq=$seqs{$id};
		my $i=0;
		while($i<length($seq)){
			if($i+80<=length($seq)){
				print OUT substr($seq,$i,80);
				print OUT "\n";
			}else{
				print OUT substr($seq,$i,length($seq)-$i);
				print OUT "\n";		
			}
			$i+=80;	
		}
		
	}
}
close TXT;
close OUT;
