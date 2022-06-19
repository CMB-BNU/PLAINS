# PLAINS: A streamlined, comprehensive pipeline for prediction and analysis of long insertions using whole-genome resequencing

## Dependencies
You can configure softwares in PLAINS/configure or add them to $PATH
### 1. Assembling, placing and calling presence/absence of novel contigs
1. Python 3+
2. Perl 5.8.0+
3. BWA
4. SAMtools 1.3+
5. BEDtools
6. Centrifuge
7. RepeatMasker 
8. MaSuRCA 4+
9. MUMmer 

You can use conda to create a new environment and install Python, Perl, BWA, SAMtools, BEDtools, MaSuRCA and MUMmer

**Install Centrifuge:**
```bash
git clone https://github.com/infphilo/centrifuge
cd centrifuge
make
make install prefix=/path/to/install
```
**Download Centrifuge database:**
```bash
wget https://zenodo.org/record/3732127/files/h+p+v+c.tar.gz?download=1
```
Then unzip the database and move it to PLAINS/bin/

More complete help about installing Centrifuge in http://www.ccb.jhu.edu/software/centrifuge/manual.shtml

**Install RepeatMasker:**
```bash
##download prerequisites
conda install h5py
conda install TRF
conda install RMBlast
##install RepeatMasker
wget http://www.repeatmasker.org/RepeatMasker/RepeatMasker-4.1.2-p1.tar.gz
tar -xzvf RepeatMasker-4.1.2-p1.tar.gz
cd RepeatMasker
./configure
```
More complete help about prerequisites, RepeatMasker installation and the main RepeatMasker library supplementary in http://www.repeatmasker.org/RepeatMasker/

### 2. Analysing functional effects of placed contigs
1. Python
2. Perl
3. R 4.0+ (packages: 1.optparse 2.clusterProfiler)
4. GeMoMa

You can use conda to install Python, Perl, R 4.0+ and GeMoMa, then install required R packages

**Install optparse:**
```R
install.packages("optparse")
```
**Install clusterProfiler:**
```R
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("clusterProfiler")
```
## Installation

```bash
git clone https://github.com/CMB-BNU/PLAINS.git
echo "export PATH=\$PATH:PLAINS/bin" >> ~/.bashrc
source ~/.bashrc
```

## Running
### 1. Assembling, placing and calling presence/absence of novel contigs
	Usage: bin/plains.sh [-h] [-t] [-r] [-b] [-s] [-o]
		-h: Print help message
		-t: Number of threads [Default 8]
		-r: Reference genome, needs to be indexed by bwa and samtools
		-b: Dir only contains your bam files
		-s: Species for Repeatmasker [The species name must be a valid NCBI Taxonomy Database species name and be contained in the RepeatMasker repeat database. For example: human, mouse, mammal, "ciona savignyi", Default plants]
		-o: Output dir [Default out]

**Example:**
```bash
bin/plains.sh -t 8 -r reference.fa -b bamdir -s plants -o out
```
### 2. Analysing functional effects of placed contigs
	Usage: bin/plains_function.sh [-h] [-t] [-r] [-g] [-a] [-p] [-o]
		-h: Print help message
		-t: Number of threads [Default 8]
		-r: Reference genome
		-g: GFF file
		-a: GO annotation file
		-p: Population or species information file [Optional, if provided, PLAINS will analyze unique and shared insertions]
		-o: Output dir of plains.sh [Default out]

**Example:**
```bash
bin/plains_function.sh -t 8 -r reference.fa -g ref.gff -a go_anno.txt -p pop_info -o out
```
Example of GFF file: 

	QKZY01000017    EVM     gene    2291    2806    .       +       .       ID=JMA008113;Name=JMA008113.1
	QKZY01000017    EVM     mRNA    2291    2806    .       +       .       ID=JMA008113.1;Parent=JMA008113;Name=JMA008113.
	QKZY01000017    EVM     exon    2291    2806    .       +       .       ID=JMA008113.1.exon1;Parent=JMA008113.1
	QKZY01000017    EVM     CDS     2291    2806    .       +       0       ID=cds.JMA008113.1;Parent=JMA008113.1
	QKZY01000017    EVM     gene    7013    8226    .       -       .       ID=JMA008110;Name=JMA008110.1
	QKZY01000017    EVM     mRNA    7013    8226    .       -       .       ID=JMA008110.1;Parent=JMA008110;Name=JMA008110.
	QKZY01000017    EVM     exon    8175    8226    .       -       .       ID=JMA008110.1.exon1;Parent=JMA008110.1
	QKZY01000017    EVM     CDS     8175    8226    .       -       0       ID=cds.JMA008110.1;Parent=JMA008110.1

Example of GO annotation file:

	JMA000003.1     GO:0009507  
	JMA000003.1     GO:0000287  
	JMA000003.1     GO:0004497  
	JMA000003.1     GO:0016984  
	JMA000003.1     GO:0009853  
	JMA000003.1     GO:0019253  
	JMA000010.1     GO:0051513  
	JMA000011.1     GO:0003676  

Example of Population or species information file (Separated by tab):

	test1.bam	pop1
	test2.bam	pop1
	test3.bam	pop2
	test4.bam	pop2

If this file was provided, PLAINS will try to find unique insertions for each population or species and insertions shared among all populations or species and analyze there functional effects.

## Output files
### 1. Assembling, placing and calling presence/absence of novel contigs
1. placed_contig.fasta:&emsp;Placed contig sequences (Long insertions)  
2. placed_loci.txt:&emsp;Locations of placed contigs  
3. placed_contig_gt.txt:&emsp;Presence/absence of placed contigs  
4. unplaced_contig.fasta:&emsp;Unplaced contig sequences  
5. unplaced_contig_gt.txt:&emsp;Presence/absence of unplaced contigs
### 2. Analysing functional effects of placed contigs
1. placed_contig.gff:&emsp;GFF file of genes in placed contigs
2. placed_gff_gene.txt:&emsp;Genes in placed contigs
3. ins_gene.txt:&emsp;Genes whose bodies were inserted
4. upstream_gene.txt:&emsp;Genes whose 5kb upstream were inserted
5. go:&emsp;Directory contains GO enrichment results
6. pop:&emsp;Directory contains results of functional effects analysis for unique and shared insertions
## Citation
Please cite:
