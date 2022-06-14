#!/usr/bin/perl
$one_deltafile=$ARGV[0];
$two_deltafile=$ARGV[1];
$fasta=$ARGV[2];
$out_delta=$ARGV[3];
$out_fasta=$ARGV[4];
open(ONE,"$one_deltafile")or die "$!";
open(TWO,"$two_deltafile")or die "$!";
open(FAS,"$fasta")or die "$!";
open(FOUT,">$out_fasta")or die "$!";
open(DOUT,">$out_delta")or die "$!";
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
@ones=<ONE>;
@twos=<TWO>;
foreach(@ones){
	if(/>(.*?):(.*?)-(.*?)\(.\) (.*?):.*/){
		$chr=$1;
		$b=$2;
		$e=$3;
		$contig=$4;
	}else{
		/(.*?) (.*?) .*/;
		$start=$b+$1;
		$end=$b+$2;
		push @one_deltas,"$contig-$chr-$start-$end";
	}
}
foreach $contig(@one_deltas){
	next if ($remove=~ /$contig/);
	@parts=split("-",$contig);
	$id=$parts[0];
	$chr=$parts[1];
	$start=$parts[2];
	$end=$parts[3];
	$contigid=$id;
	foreach $contig(@one_deltas){
		@parts=split("-",$contig);
		next if($parts[0] eq $id);
		next if($parts[1] ne $chr);
		next if($parts[2]>$end and $parts[2]-$end>5000);
		next if($parts[3]<$start and $start-$parts[3]>5000);
		$remove.= "$contig;";
		$contigid.="-$parts[0]";
	}
	push @ids,$contigid;
}
foreach $id(@ids){
	if($id=~ /-/){
		$redun_seq= Find_redun($id);
		if ($redun_seq eq ""){
			@lls=split("-",$id);
			foreach (@lls){
				push @final_id,$_;
			}
		}else{
		$longest_id= Find_longest_seq($redun_seq);
		push @final_id,$longest_id;
		}	
	}else{
		push @final_id,$id;
	}
}
foreach $id(@final_id){
	$right=0;
	foreach(@ones){
		if($_=~ />/ and $_=~ /$id/){
			print DOUT;
			$right=1;
		}elsif($right==1){
			print DOUT;
			$right=0;
		}	
	}
}
foreach $id(@final_id){
	foreach (keys %seqs){
		if($_=~/$id/){
			print FOUT ">$_\n";
			$seq=$seqs{$_}
		}
	}
	$i=0;
	while($i<length($seq)){
		if($i+80<=length($seq)){
			print FOUT substr($seq,$i,80);
			print FOUT "\n";
		}else{
			print FOUT substr($seq,$i,length($seq)-$i);
			print FOUT "\n";		
		}
			$i+=80;	
		}
}
close ONE;
close TWO;
close FOUT;
close DOUT;
sub Find_redun{
	my $contiglist="";
	my $list=shift;
	my @ids=split("-",$list);
	foreach $id1(@ids){
		foreach $id2(@ids){
			next if ($id2 eq $id1);
			next if ($rm=~ /$id1-$id2/ or $rm=~/$id2-$id1/);
			foreach $line(@twos){
				if($line=~ />.*$id1.*$id2/){
					$select=1;
					$line=~/>(.*?) (.*?) (.*?) (.*?)\n/;
					$contig1=$1;
					$contig2=$2;
					$len1=$3;
					$len2=$4;
					next;
				}
				if($select==1){
					$line=~/(.*?) (.*?) (.*?) (.*?) (.*?) .*/;
					$match_len1=$2-$1+1;
					$match_len2=$4-$3+1;
					$wrong=$5;
					$w=$wrong/$match_len1;
					if ($w<0.02){
						if ($match_len1/$len1 >=0.95 or $match_len2/$len2>=0.95){
							unless($contiglist=~ /$id1/){
								$contiglist.="$id1-";
							}
							unless($contiglist=~ /$id2/){
								$contiglist.="$id2-";
								$rm.="$id1-$id2=";
							}
						}
					}
					$select=0;
					next;
				}
			}
		}
	}
	chop($contiglist);
print "$contiglist\n";
	return $contiglist;
}
sub Find_longest_seq{
	my $list=shift;
	my %lens;
	my $m;
	my @ids=split("-",$list);
	my $longestid;
	foreach $id(@ids){
		foreach (keys %seqs){
                	if($_=~ /$id/){
                	        $seq=$seqs{$_};
                	}
		}
		$len=length($seq);
		$lens{$id}=$len;
	}
	foreach $id(keys %lens){
		$m=1;
		$len=$lens{$id};
		foreach (keys %lens){
			if($len<$lens{$_}){
				$m=0;
			}
		}
		if ($m == 1){
			$longest_id=$id;
print "$longest_id\n";
		}
	}
	return $longest_id;
}
