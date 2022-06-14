#!/usr/bin/perl
$filename=$ARGV[0];
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
open(TXT,"$ARGV[1]") or die "can't open,$!";
@txt=<TXT>;
open(OUT1,">$ARGV[2]")or die "can't write ,$!";
open(OUT2,">$ARGV[3]")or die "can't write ,$!";
foreach $id (keys %seqs) {
	$index=0;
	$len=length($seqs{$id});
	foreach(@txt){
		@parts=split(" ",$_);
		if($parts[1] eq $id){
			if($parts[3]==0 or $parts[4]==$len){
				print OUT1 $_;
				$index=1;
			}
		}
	}
	next unless ($index=1);
	print OUT2 ">$id\n";
	my $seq=$seqs{$id};
	my $i=0;
	while($i<length($seq)){
		if($i+80<=length($seq)){
			print OUT2 substr($seq,$i,80);
			print OUT2 "\n";
		}else{
			print OUT2 substr($seq,$i,length($seq)-$i);
			print OUT2 "\n";		
		}
		$i+=80;	
	}
}
close OUT1;
close OUT2;
close TXT;
