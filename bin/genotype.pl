#!/usr/bin/perl
$list=$ARGV[0];
$fasta=$ARGV[1];
$out=$ARGV[2];
$workpath=$ARGV[3];
$nucmer=$ARGV[4];
$show_coords=$ARGV[5];

open(LIST,"$list")or die"$!";
while(<LIST>){
	chomp;
	push @juglans,$_;
}
close LIST;
open(FAS,"$fasta")or die "$!";
while(<FAS>){
	chomp;
	if(/^>/){
		$_=~ s/>//;
		push @contigs,$_;
	}
}
close FAS;
open(OUT,">$out")or die"$!";
foreach(@juglans){
	$head.="$_\t";
}
chop $head;
print OUT "ID\tName\t";
print OUT "$head\n";
`cd $workpath`;
foreach $juglan(@juglans){
	`$nucmer --maxmatch -p $juglan $fasta $workpath/$juglan.scf.fasta`;
	`mv $juglan.delta $workpath/$juglan.delta`;
	`$show_coords -H -T -l -c -o $workpath/$juglan.delta >$workpath/$juglan.coord`;
}
$i=1;
foreach $contig(@contigs){
	print OUT "Placed_contig-$i\t$contig";
	$i++;
	foreach $juglan(@juglans){
		open(IN,"$workpath/$juglan.coord")or die"$!";
		if($contig=~ /$juglan:/){
			$identity="yes";
		}
		while(<IN>){
			if(/$contig/ and /IDENTITY/){
				$identity="yes";
			}	
		}
		close IN;
		if($identity eq "yes"){
			print OUT "\t1";
			$num++;
		}else{
			print OUT "\t0";
		}
		$identity="";
	}
	print OUT "\n";
	$nums{$num}+=1;
	$num=0;
}
close OUT;
#for($i=1;$i<=80;$i++){
#	if(exists($nums{$i})){
#		print "$i\t$nums{$i}\n";
#	}else{
#		print "$i\t0\n";
#	}
#}
