#!/usr/bin/python
import sys
import re
input_gff=sys.argv[1]
output_gff=sys.argv[2]
gff=open(input_gff,'r')
out=open(output_gff,'w')
i=1
refgene={}
for line in gff:
	if line.startswith('#'):
		out.write(line)
	else:
		parts=line.split("\t")
		if parts[2] == "gene":
			j=str(i)
			gene_id="gene_"+j
			i+=1
			old_id=re.findall("ID=(.*?);",line)[0]
			newline=line.replace(old_id,gene_id)
			out.write(newline)
		elif parts[2] == "mRNA":
			parent=re.findall(";Parent=(.*?);",line)[0]
			newline=line.replace(parent,gene_id)
			old_id=re.findall("ID=(.*?);",line)[0]
			refgene_id=re.findall(";ref-gene=(.*?);",line)[0]
			if refgene_id in refgene.keys():
				refgene[refgene_id]+=1
			else:
				refgene[refgene_id]=1
			num=str(refgene[refgene_id])
			mrna_id=refgene_id+"_"+num
			newline2=newline.replace(old_id,mrna_id)
			out.write(newline2)
		elif parts[2] == "CDS":
			old_par=re.findall("Parent=(.*?)\n",line)[0]
			newline=line.replace(old_par,mrna_id)
			out.write(newline)
gff.close()
out.close()
