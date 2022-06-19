#!/bin/bash

#softwares
dir=`dirname $0`
if [ ${dir:0:1} != "/"  ]; then
	scriptpath=`pwd`"/"`dirname $0`
else
	scriptpath=`dirname $0`
fi
echo "PLAINS scripts in: $scriptpath"

while read line
do
	software=`echo $line|awk '{print $1}'`
	case $software in
	BWA)
		bwa=`echo $line|awk '{print $2}'`
		;;
	SAMtools)
		samtools=`echo $line|awk '{print $2}'`
		;;
	BEDtools)
		bedtools=`echo $line|awk '{print $2}'`
		;;
	Centrifuge)
		centrifuge=`echo $line|awk '{print $2}'`
		;;
	centrifuge_kreport)
		centrifuge_kreport=`echo $line|awk '{print $2}'`
		;;
	RepeatMasker)
		repeatmasker=`echo $line|awk '{print $2}'`
		;;
	MaSuRCA)
		masurca=`echo $line|awk '{print $2}'`
		;;
	NUCmer)
		nucmer=`echo $line|awk '{print $2}'`
		;;
	show_coords)
		show_coords=`echo $line|awk '{print $2}'`
		;;
	esac
done<$scriptpath/../configure
echo "configure file in: $scriptpath/../configure"

#bwa=bwa
#samtools=samtools
#bedtools=bedtools
#centrifuge=centrifuge
#centrifuge_kreport=centrifuge-kreport
#repeatmasker=RepeatMasker
#masurca=masurca
#nucmer=nucmer
#show_coords=show-coords

#parameters
Usage (){
	echo -e "\n\t\tUsage:  bin/plains.sh [-h] [-t] [-r] [-b] [-s] [-o]\n"
	echo -e "\t\t\t-h: Print help message"
	echo -e "\t\t\t-t: Number of threads [Default 8]"
	echo -e "\t\t\t-r: Reference genome, needs to be indexed by bwa and samtools"
	echo -e "\t\t\t-b: Dir only contains your bam files"
	echo -e "\t\t\t-s: Species for Repeatmasker [The species name must be a valid NCBI Taxonomy Database species name and be contained in the RepeatMasker repeat database. For example: human, mouse, mammal, "ciona savignyi", Default plants]"
	echo -e "\t\t\t-o: Output dir [Default out]\n"
	exit 1
}

np=8
outpath=`pwd`"/out"
species='plants'
while getopts ht:r:b:o:s: varname
do
	case $varname in
	h)
		Usage
		exit
		;;
	t)
		np=$OPTARG
		;;
	r)
		ref_fasta=$OPTARG
		if [ ${ref_fasta:0:1} != "/"  ]; then
			ref_fasta=`pwd`"/"$ref_fasta
		fi
		if [ ! -f $ref_fasta ];then
			echo "The ref file $ref_fasta not exist"
			exit
		fi
		;;
	b)
		bampath=$OPTARG
		if [ ${bampath:0:1} != "/"  ]; then
			bampath=`pwd`"/"$bampath
		fi
		if [ ! -d $bampath ];then
			echo "The bam path $bampath not exist"
			exit	
		fi
		;;
	o)
		outpath=$OPTARG
		if [ ${outpath:0:1} != "/"  ]; then
			outpath=`pwd`"/"$outpath
		fi
		;;
	s)
		species=$OPTARG
		;;
	:)
		echo "the option -$OPTARG require an arguement"
		exit 1
		;;
	?)
		echo "Invaild option: -$OPTARG"
		exit 2
		;;
	esac
done

workpath=`pwd`"/plains_work"
if [ ! -d $workpath ]; then
	mkdir $workpath
fi
ls $bampath> $workpath/bamfiles
list=$workpath/bamfiles
#scriptpath=`pwd`"/"`dirname $0`
start_time=`date +%Y%m%d-%H:%M`

echo "Start_time: $start_time"
echo "--Number of threads: $np"
echo "--Work dir: $workpath"
echo "--Reference genome: $ref_fasta"
echo "--List of bam files: $workpath/bamfiles"

#get unaligned reads and assembly
if [ ! -d $workpath/unmap_fq ]; then
	mkdir  $workpath/unmap_fq
fi
if [ ! -d $workpath/link_bam ]; then
	mkdir $workpath/link_bam
fi
if [ ! -d $workpath/log ]; then
	mkdir $workpath/log
fi

while read line
do
	$samtools fastq -f 12 $bampath/${line} -1 $workpath/unmap_fq/${line}_mateUnmapped_R1.fq -2 $workpath/unmap_fq/${line}_mateUnmapped_R2.fq >>$workpath/log/${line}.unalignseq.log 2>&1
	$samtools fastq -f 68 -F 8 $bampath/${line} 1> $workpath/unmap_fq/${line}_R1_mateUnmapped.fq 2>>$workpath/log/${line}.unalignseq.log
	$samtools fastq -f 132 -F 8 $bampath/${line} 1> $workpath/unmap_fq/${line}_R2_mateUnmapped.fq 2>>$workpath/log/${line}.unalignseq.log
	$samtools view -bS -f 8 -F 4 $bampath/${line} 1> $workpath/link_bam/${line}_Links.bam 2>>$workpath/log/${line}.unalignseq.log
done<$list

getseq_time=`date +%Y%m%d-%H:%M`
echo "Obtain unaligned reads: $getseq_time"

if [ ! -d $workpath/masurca_config ]; then
	mkdir $workpath/masurca_config
fi

perl $scriptpath/mkconfig.pl $workpath/unmap_fq $workpath/masurca_config $list $np

if [ ! -d $workpath/masurca_work ]; then
	mkdir $workpath/masurca_work
fi
if [ ! -d $workpath/unfilter_fa ]; then
	mkdir $workpath/unfilter_fa
fi
if [ ! -d $workpath/filter_fa ]; then
	mkdir $workpath/filter_fa
fi

while read line
do
	mkdir $workpath/masurca_work
	cd $workpath/masurca_work
	$masurca $workpath/masurca_config/${line}.config 1>>$workpath/log/${line}.masurca.log 2>>$workpath/log/${line}.masurca.log
	bash assemble.sh 1>>$workpath/log/${line}.masurca.log 2>>$workpath/log/${line}.masurca.log
	if [ -f CA/final.genome.scf.fasta ]; then
		mv CA/final.genome.scf.fasta $workpath/unfilter_fa/${line}.scf.fasta
	elif [ -f CA/primary.genome.scf.fasta ]; then
		mv CA/primary.genome.scf.fasta $workpath/unfilter_fa/${line}.scf.fasta
	fi
#	rm -rf *
	cd ..
	rm -rf $workpath/masurca_work
	perl $scriptpath/fil_fasta.pl $workpath/unfilter_fa/${line}.scf.fasta $workpath/filter_fa/${line}.over1kb.fasta
done<$list

assembly_time=`date +%Y%m%d-%H:%M`
echo "Finish assembly: $assembly_time"

if [ ! -d $workpath/centrifuge_result ]; then
	mkdir $workpath/centrifuge_result
fi
if [ ! -d $workpath/fil_centrifuge ]; then
	mkdir $workpath/fil_centrifuge
fi
if [ ! -d $workpath/masked_fa ]; then
	mkdir $workpath/masked_fa
fi

cd $scriptpath
while read line
do
	$centrifuge --report-file $workpath/centrifuge_result/${line}.csv -x hpvc -k 1 --host-taxids 9606 -f $workpath/filter_fa/${line}.over1kb.fasta >$workpath/centrifuge_result/${line}.txt 2>>$workpath/log/${line}.centrifuge.log
	$centrifuge_kreport -x hpvc $workpath/centrifuge_result/${line}.txt --min-score 0 --min-length 0 > $workpath/centrifuge_result/${line}.krakenOut 2>>$workpath/log/${line}.centrifuge.log
	perl $scriptpath/fil_centrifuge.pl $workpath/filter_fa/${line}.over1kb.fasta $workpath/centrifuge_result/${line}.txt $workpath/fil_centrifuge/${line}.fasta
	$repeatmasker -species $species -nolow $workpath/fil_centrifuge/${line}.fasta 1>>$workpath/log/${line}.repeatmasker.log 2>>$workpath/log/${line}.repeatmasker.log
	if [ -f $workpath/fil_centrifuge/${line}.fasta.masked ]; then
		perl $scriptpath/write_fasta.pl $workpath/fil_centrifuge/${line}.fasta.masked $workpath/masked_fa/${line}.masked.fasta
	else
		cp $workpath/fil_centrifuge/${line}.fasta $workpath/masked_fa/${line}.masked.fasta
	fi
done<$list

fil_time=`date +%Y%m%d-%H:%M`
echo "Filter contigs: $fil_time"
if [ ! -d $workpath/mateunmap ]; then
	mkdir $workpath/mateunmap
fi
if [ ! -d $workpath/bwa_result ]; then
	mkdir $workpath/bwa_result
fi
if [ ! -d $workpath/fil_contig ]; then
	mkdir $workpath/fil_contig
fi

while read line
do
	cat $workpath/unmap_fq/${line}_R1_mateUnmapped.fq $workpath/unmap_fq/${line}_R2_mateUnmapped.fq > $workpath/mateunmap/${line}.fq
	$bwa index $workpath/masked_fa/${line}.masked.fasta 2>>$workpath/log/${line}.bwa.log
	$bwa mem -M -t $np $workpath/masked_fa/${line}.masked.fasta $workpath/mateunmap/${line}.fq 1> $workpath/bwa_result/${line}.readContigAlignment.sam 2>>$workpath/log/${line}.bwa.log
	$samtools view -b -h -F 256 $workpath/bwa_result/${line}.readContigAlignment.sam > $workpath/bwa_result/${line}.readContigAlignment.bam
	$samtools sort  $workpath/bwa_result/${line}.readContigAlignment.bam -o  $workpath/bwa_result/${line}.readContigAlignment.sort.bam
	$bedtools bamtobed -i  $workpath/bwa_result/${line}.readContigAlignment.sort.bam > $workpath/bwa_result/${line}.readContigAlignment.bed
	cat $workpath/bwa_result/${line}.readContigAlignment.bed |awk '{OFS="\t"}{print $4,$1,$6,$2,$3}' | sort > $workpath/bwa_result/${line}.readContigAlignment.txt
	rm $workpath/bwa_result/${line}.readContigAlignment.sam
	rm $workpath/bwa_result/${line}.readContigAlignment.bam
	rm $workpath/bwa_result/${line}.readContigAlignment.sort.bam
	rm $workpath/bwa_result/${line}.readContigAlignment.bed
	$samtools view -H $workpath/link_bam/${line}_Links.bam |  cat - <(awk 'FNR==NR{main[$1]=$0;next} $1 in main {print main[$1]}' <($samtools view $workpath/link_bam/${line}_Links.bam) $workpath/bwa_result/${line}.readContigAlignment.txt) | $samtools sort -n -o $workpath/bwa_result/${line}.tmp.bam
	$bedtools bamtobed -i $workpath/bwa_result/${line}.tmp.bam | awk '{OFS="\t"}{print $4,$1,$6,$2,$3}' | sed -e 's/\/[1-2]//g' | sort> $workpath/bwa_result/${line}.matchedMates.txt
	rm $workpath/bwa_result/${line}.tmp.bam
	join -j 1 $workpath/bwa_result/${line}.readContigAlignment.txt $workpath/bwa_result/${line}.matchedMates.txt > $workpath/bwa_result/${line}.mateLinks.txt
        perl $scriptpath/contigend.pl  $workpath/masked_fa/${line}.masked.fasta $workpath/bwa_result/${line}.mateLinks.txt $workpath/fil_contig/${line}.contigend.txt $workpath/fil_contig/${line}.contigend.link.fasta
done<$list
 
cut -f 1,2 ${ref_fasta}.fai >$workpath/chrlen.txt
if [ ! -d $workpath/seq ]; then
	mkdir $workpath/seq
fi
cd $workpath
while read line
do
	perl $scriptpath/fil_chr.pl $workpath/fil_contig/${line}.contigend.txt $workpath/fil_contig/${line}.chrunique.txt 
	perl $scriptpath/fil_region.pl $workpath/fil_contig/${line}.chrunique.txt $workpath/fil_contig/${line}.regionunique.txt
#       cut -d " " -f 2 $workpath/fil_contig/${line}.regionunique.txt|sort -n|uniq >$workpath/fil_contig/${line}.regionunique.contigid.txt
	perl $scriptpath/filter_region.pl $workpath/fil_contig/${line}.regionunique.txt $workpath/fil_contig/${line}.contig.txt $workpath/fil_contig/${line}.chr.txt
	perl $scriptpath/get_seq.pl ${line} contig $workpath/fil_contig/${line}.contig.txt $workpath/fil_centrifuge/${line}.fasta $samtools
	perl $scriptpath/get_seq.pl ${line} chr $workpath/fil_contig/${line}.chr.txt $ref_fasta $samtools
	mv $workpath/${line}.chr.fasta $workpath/seq/${line}.chr.fasta
	mv $workpath/${line}.contig.fasta $workpath/seq/${line}.contig.fasta
done<$list

#matelink_time=`date +%Y%m%d-%H:%M`
#echo "matelink_time=$matelink_time"

if [ ! -d $workpath/bed ]; then
	mkdir $workpath/bed
fi
mv $workpath/fil_contig/*.fasta $workpath/seq/
while read line
do
	cd  $workpath/seq
	$nucmer --maxmatch -l 15 -b 1 -c 15 -p ${line} $workpath/seq/${line}.chr.fasta $workpath/seq/${line}.contig.fasta
	perl $scriptpath/fil_delta_consis.pl $workpath/seq/${line}.delta $workpath/seq/${line}.delta.f1
	perl $scriptpath/fil_delta_end.pl $workpath/seq/${line}.delta.f1 $workpath/seq/${line}.delta.f
	rm $workpath/seq/${line}.delta.f1
#       perl $scriptpath/fil_delta_twoend.pl $workpath/seq/${line}.delta.f $workpath/seq/twoend.delta
	perl $scriptpath/write_bed.pl $workpath/seq/${line}.delta.f $workpath/bed/${line}.left.bed $workpath/bed/${line}.right.bed $line
done<$list

placed_time=`date +%Y%m%d-%H:%M`
echo "Placed contigs: $placed_time"

cat $workpath/bed/*.left.bed>$workpath/bed/left.bed
cat $workpath/bed/*.right.bed>$workpath/bed/right.bed
$bedtools sort -i $workpath/bed/left.bed >$workpath/bed/left.sort.bed
$bedtools sort -i $workpath/bed/right.bed >$workpath/bed/right.sort.bed
$bedtools merge -d 100 -c 4 -o distinct -i $workpath/bed/left.sort.bed >$workpath/bed/left.merged.bed
$bedtools merge -d 100 -c 4 -o distinct -i $workpath/bed/right.sort.bed >$workpath/bed/right.merged.bed

if [ ! -d $workpath/all_left_cluster ]; then
	mkdir $workpath/all_left_cluster
fi
if [ ! -d $workpath/all_right_cluster ]; then
	mkdir $workpath/all_right_cluster
fi

perl $scriptpath/cluster.pl $workpath/bed/left.merged.bed $workpath/fil_centrifuge $workpath/all_left_cluster
perl $scriptpath/cluster.pl $workpath/bed/right.merged.bed $workpath/fil_centrifuge $workpath/all_right_cluster

cp $scriptpath/verify.pl $workpath/all_left_cluster/verify.pl
cp $scriptpath/verify.pl $workpath/all_right_cluster/verify.pl
cd  $workpath/all_left_cluster
perl verify.pl $nucmer
cd $workpath/all_right_cluster
perl verify.pl $nucmer

if [ -f $workpath/all_left_cluster/left.longest.fasta ]; then
	rm $workpath/all_left_cluster/left.longest.fasta
fi
if [ -f $workpath/all_right_cluster/right.longest.fasta ]; then
	rm $workpath/all_right_cluster/right.longest.fasta
fi
if [ -f $workpath/longest.fasta ]; then
	rm $workpath/longest.fasta
fi
cat $workpath/all_left_cluster/*longest.fasta >$workpath/all_left_cluster/left.longest.fasta
cat $workpath/all_right_cluster/*longest.fasta >$workpath/all_right_cluster/right.longest.fasta
cat $workpath/all_left_cluster/left.longest.fasta $workpath/all_right_cluster/right.longest.fasta >$workpath/longest.fasta
cd $workpath
$nucmer --maxmatch --nosimplify -p redundant $workpath/longest.fasta $workpath/longest.fasta
perl $scriptpath/longest_delta_stat.pl $workpath/longest.fasta $workpath/longest.delta.txt $workpath/seq
perl $scriptpath/de_redun.pl $workpath/longest.delta.txt $workpath/redundant.delta $workpath/longest.fasta $workpath/longest.deredun.detla $workpath/longest.deredun.fasta

if [ -f $workpath/longest.deredun.trim.fasta ]; then
	rm $workpath/longest.deredun.trim.fasta
fi
if [ -f $workpath/longest.deredun.fasta.fai ]; then
	rm $workpath/longest.deredun.fasta.fai
fi

perl $scriptpath/trim.pl $workpath/longest.deredun.fasta $workpath/longest.deredun.detla $workpath/longest.deredun.trim.fasta $samtools 

cluster_time=`date +%Y%m%d-%H:%M`
echo "Cluster contigs: $cluster_time"
perl $scriptpath/genotype.pl $list $workpath/longest.deredun.trim.fasta $workpath/genotype.txt $workpath/unfilter_fa $nucmer $show_coords
python $scriptpath/write_loci.py $workpath/bed/left.merged.bed $workpath/bed/right.merged.bed $workpath/genotype.txt $workpath/placed_loci.txt

#unplaced contigs
if [ ! -d $workpath/unplaced ]; then
	mkdir $workpath/unplaced
fi
python $scriptpath/get_unplaced.py $list $workpath/fil_centrifuge $workpath/bed $workpath/unplaced/unplaced_underen.fasta
$nucmer --maxmatch --nosimplify -l 31 -c 100 -p $workpath/unplaced/cluster $workpath/unplaced/unplaced_underen.fasta $workpath/unplaced/unplaced_underen.fasta 1>>$workpath/log/unplaced.log 2>>$workpath/log/unplaced.log
$show_coords -H -T -l -c -o $workpath/unplaced/cluster.delta > $workpath/unplaced/cluster.coord
python $scriptpath/cluster_unplaced.py $workpath/unplaced/unplaced_underen.fasta $workpath/unplaced/cluster.coord $workpath/unplaced/unplaced_deren.fasta
$nucmer -p $workpath/unplaced/verify $workpath/seq/longest.deredun.fasta $workpath/unplaced/unplaced_deren.fasta 1>>$workpath/log/unplaced.log 2>>$workpath/log/unplaced.log
$show_coords -H -T -l -c -o $workpath/unplaced/verify.delta >$workpath/unplaced/verify.coord
python $scriptpath/verify_unplaced.py $workpath/unplaced/unplaced_deren.fasta $workpath/unplaced/verify.coord $workpath/unplaced/unplaced_final.fasta
perl $scriptpath/unplaced_genotype.pl $list $workpath/unplaced/unplaced_final.fasta $workpath/unplaced_genotype.txt $workpath/unfilter_fa $nucmer $show_coords

unplaced_time=`date +%Y%m%d-%H:%M`
echo "Finish unplaced contigs: $unplaced_time"

#output
if [ ! -d $outpath ]; then
	mkdir -p $outpath
fi

mv $workpath/longest.deredun.trim.fasta $outpath/placed_contig.fasta
mv $workpath/genotype.txt $outpath/placed_contig_gt.txt
mv $workpath/unplaced/unplaced_final.fasta $outpath/unplaced_contig.fasta
mv $workpath/unplaced_genotype.txt $outpath/unplaced_genotype.txt
mv $workpath/placed_loci.txt $outpath/placed_loci.txt

end_time=`date +%Y%m%d-%H:%M`

echo "Complete: $start_time -------> $end_time"
echo "Output files in $outpath"
