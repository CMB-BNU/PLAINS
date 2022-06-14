import sys
import re

gff_file=sys.argv[1]


with open(gff_file) as lines:
	for line in lines:
		if line[0] == "#":
			continue
		if line.split("\t")[2]=="mRNA":
			gene_id=re.findall(";ref-gene=(.*?);",line)[0]+".1"
			print(gene_id)
