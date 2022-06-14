#!/sur/bin/perl
$bed=$ARGV[0];
#$contigpath='/data1/chenyd_data/j4_pcr_bam/unmap/assembly/fil_centrifuge';
$contigpath=$ARGV[1];
$outpath=$ARGV[2];
open(IN,"$bed")or die "can't open $bed,$!";
while(<IN>){
	chomp;
	@lines=split("\t",$_);
	$clusterid="$lines[0]:$lines[1]-$lines[2]";
	if ($lines[3]=~ /,/){
		@lists=split(",",$lines[3]);
		foreach $list(@lists){
			@contigs=split(":",$list);
			open(FAS,"$contigpath/$contigs[0].fasta") or die"$!";
			$or=$/;
			$/=">";
			while(<FAS>){
				next if /^>$/;
				/(.*?)\n(.*)/s;
				$name=$1;
				$id ="$contigs[0]:$name";
				$seq = "\U$2";
				$seq=~ s/\n//g;
				$seq=~ s/>//g;
				if($name eq $contigs[1]){
					$seqs{$id}=$seq;
				}
			}
			$/=$or;
			close FAS;
		}
		open(FAS,">$outpath/$clusterid.fasta")or die "$!";
		foreach $hashid (keys %seqs) {
			print FAS ">$hashid\n";
			my $seq=$seqs{$hashid};
			my $i=0;
			$len=length($seq);
			$lengths{$hashid}=$len;
			while($i<length($seq)){
				if($i+80<=length($seq)){
					print FAS substr($seq,$i,80);
					print FAS "\n";
				}else{
					print FAS substr($seq,$i,length($seq)-$i);
					print FAS "\n";		
				}
				$i+=80;	
			}
		}
		close FAS;
		open(LON,">$outpath/$clusterid.longest.fasta")or die"$!";
		foreach (keys %lengths){
			if($lengths{$_}>=$l){
				$l=$lengths{$_};
				$longest_id=$_;
			}else{
				next;
			}
		}
		print LON ">$longest_id\n";
		my $seq=$seqs{$longest_id};
                my $i=0;
                while($i<length($seq)){
                        if($i+80<=length($seq)){
                                print LON substr($seq,$i,80);
                                print LON "\n";
                        }else{
                                print LON substr($seq,$i,length($seq)-$i);
                                print LON "\n";
                        }
                        $i+=80;
                }
		close LON;
		%seqs=();
		%lengths=();
		$l=0;
	}else{
		@contigs=split(":",$lines[3]);
		open(FAS,"$contigpath/$contigs[0].fasta") or die"$!";
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
		open(OUT,">$outpath/$clusterid.fasta")or die"$!";
		print OUT ">$contigs[0]:$contigs[1]\n";
		my $seq=$seqs{$contigs[1]};
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
		close OUT;
		%seqs=();
		`cp $outpath/$clusterid.fasta $outpath/$clusterid.longest.fasta`;
	}
}
close IN;
