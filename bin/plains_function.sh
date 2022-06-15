#!/bin/bash

scriptpath=`pwd`"/"`dirname $0`
#softwares
#gemoma="GeMoMa"
while read line
do
	software=`echo $line|awk '{print $1}'`
	case $software in
	gemoma)
		gemoma=`echo $line|awk '{print $2}'`
		;;
	esac
done<$scriptpath/../configure

#parameters
Usage (){
	echo -e "\n\t\tUsage: bin/plains_function.sh [-h] [-t] [-r] [-g] [-a] [-p] [-o]\n"
	echo -e "\t\t\t-h: Show this help"
	echo -e "\t\t\t-t: Number of threads [Default 8]"
	echo -e "\t\t\t-r: Reference genome"
	echo -e "\t\t\t-g: GFF file"
	echo -e "\t\t\t-a: GO annotation file"
	echo -e "\t\t\t-p: Population or species information file [Optional, if provided, PLAINS will analyze unique and shared insertions]"
	echo -e "\t\t\t-o: PLAINS output dir [Default out]\n"
}

np=8
plains_dir=`pwd`"/out"
workpath=`pwd`"/plains_work"
pop=""
#scriptpath=`pwd`"/"`dirname $0`
while getopts ht:r:g:a:p:o: varname
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
		if [ ! -f $ref_fasta ]; then
			echo "The ref file $ref_fasta not exist"
			exit
		fi
		;;
	g)
		gff_file=$OPTARG
		if [ ${gff_file:0:1} != "/"  ]; then
			gff_file=`pwd`"/"$gff_file
		fi
		if [ ! -f $gff_file ]; then
			echo "The gff file $gff_file not exist"
			exit
		fi
		;;
	o)
		plains_dir=$OPTARG
		if [ ${plains_dir:0:1} != "/"  ]; then
			plains_dir=`pwd`"/"$plains_dir
		fi
		if [ ! -d $plains_dir ]; then
			echo "The plains dir $plains_dir not exist"
			exit
		fi
		;;
	a)
		go_anno=$OPTARG
		if [ ${go_anno:0:1} != "/"  ]; then
			go_anno=`pwd`"/"$go_anno
		fi
		if [ ! -f $go_anno ]; then
			echo "GO annotation file $go_anno not exist"
			exit
		fi
		;;
	p)
		pop=$OPTARG
		;;
	esac
done

if [ ! -d $workpath ]; then
	mkdir $workpath
fi

start_time=`date +%Y%m%d-%H:%M`
echo "Start analyzing functional effects"
echo "Start_time: $start_time"
echo "--Number of threads: $np"
echo "--Work dir: $workpath"
echo "--Reference genome: $ref_fasta"
echo "--Gff file: $gff_file"
echo "--output dir: $plains_dir"

#gene inserted
perl ${scriptpath}/stat_gene.pl ${plains_dir}/placed_loci.txt $gff_file $workpath/ins_gene_body.txt 
perl ${scriptpath}/stat_upstream.pl ${plains_dir}/placed_loci.txt $gff_file $workpath/ins_gene_upstream.txt
python ${scriptpath}/get_genelist.py $workpath/ins_gene_body.txt |sort -u >${plains_dir}/ins_gene.txt
python ${scriptpath}/get_genelist.py $workpath/ins_gene_upstream.txt |sort -u>${plains_dir}/upstream_gene.txt

#gene annotation
if [ ! -d $workpath/gemoma ]; then
	mkdir $workpath/gemoma
fi
if [ ! -d $workpath/log ]; then
	mkdir $workpath/log
fi
$gemoma GeMoMaPipeline threads=$np t=${plains_dir}/placed_contig.fasta s=own d=RAW a=$gff_file g=$ref_fasta outdir=${workpath}/gemoma tblastn=true GeMoMa.p=100 GAF.a="pAA>=0.7" GAF.d="iAA,pAA,score" GAF.s="score" AnnotationFinalizer.r=NO p=true pc=true o=true tag="mRNA" 1>$workpath/log/gemoma.log 2>$workpath/log/gemoma.log
python ${scriptpath}/pro_gff.py ${workpath}/gemoma/final_annotation.gff ${plains_dir}/placed_contig.gff
python ${scriptpath}/stat_gff_gene.py ${plains_dir}/placed_contig.gff |sort -u>${plains_dir}/placed_gff_gene.txt

#go enrichment
if [ ! -d $workpath/go ]; then
	mkdir $workpath/go
fi
if [ ! -d ${plains_dir}/go ]; then
	mkdir ${plains_dir}/go
fi
Rscript ${scriptpath}/go_enrich.R -a $go_anno -c ${scriptpath}/go_class.txt -q 1 -g ${plains_dir}/ins_gene.txt -o ${plains_dir}/go/gene_body_inserted 1>>$workpath/log/go.log 2>>$workpath/log/go.log
Rscript ${scriptpath}/go_enrich.R -a $go_anno -c ${scriptpath}/go_class.txt -q 1 -g ${plains_dir}/upstream_gene.txt -o ${plains_dir}/go/gene_upstream_inserted 1>>$workpath/log/go.log 2>>$workpath/log/go.log
Rscript ${scriptpath}/go_enrich.R -a $go_anno -c ${scriptpath}/go_class.txt -q 1 -g ${plains_dir}/placed_gff_gene.txt -o ${plains_dir}/go/placed_anno_gene 1>>$workpath/log/go.log 2>>$workpath/log/go.log

#pop
if [ -f $pop ]; then
	if [ ! -d ${plains_dir}/pop ]; then
		mkdir ${plains_dir}/pop
	fi
	if [ ! -d ${plains_dir}/pop/gene ]; then
		mkdir ${plains_dir}/pop/gene
	fi
	if [ ! -d ${plains_dir}/pop/go ]; then
		mkdir ${plains_dir}/pop/go
	fi
	python ${scriptpath}/pop_stat.py $pop ${plains_dir}/placed_contig_gt.txt ${workpath}/ins_gene_body.txt ${workpath}/ins_gene_upstream.txt ${plains_dir}/placed_contig.gff ${plains_dir}/pop/pop_stat.txt ${plains_dir}/pop/gene/placed
	for genefile in `ls ${plains_dir}/pop/gene/`
	do
		Rscript ${scriptpath}/go_enrich.R -a $go_anno -c ${scriptpath}/go_class.txt -q 1 -g ${plains_dir}/pop/gene/${genefile} -o ${plains_dir}/pop/go/${genefile} 1>>$workpath/log/go.log 2>>$workpath/log/go.log
	done
fi
end_time=`date +%Y%m%d-%H:%M`
echo "Complete functional effects analysis: $start_time -------> $end_time"
echo "Output files in $plains_dir"
