import sys
import re

pop_file=sys.argv[1]
gt_file=sys.argv[2]
ins_gene_file=sys.argv[3]
upstream_gene_file=sys.argv[4]
gff_file=sys.argv[5]
out_stat_file=sys.argv[6]
out_gene_pre=sys.argv[7]

pop_info={}
pop_num={}
pop_unique={}
pop_shared={}
with open (pop_file) as lines:
	for line in lines:
		if line.replace("\n","").split("\t")[1] in pop_info.keys():
			pop_info[line.replace("\n","").split("\t")[1]].append(line.split("\t")[0])
		else:
			pop_info[line.replace("\n","").split("\t")[1]]=[line.split("\t")[0]]
			pop_num[line.replace("\n","").split("\t")[1]]=0
			pop_unique[line.replace("\n","").split("\t")[1]]={}

with open (gt_file) as lines:
	for line in lines:
		if line[0] == "I":
			samples=line.replace("\n","").split("\t")[2:]
			continue
		pops=[]
		for i in range(len(samples)):
			for key in pop_info.keys():
				if samples[i] in pop_info[key]:
					pops.append(key)
		for key in pop_num.keys():
			pop_num[key]=0
		gts=line.replace("\n","").split("\t")[2:]
		for i in range(len(gts)):
			pop_num[pops[i]]+=int(gts[i])
		for key in pop_num.keys():
			if pop_num[key]==0:
				continue
			unique=1
			for key2 in pop_num.keys():
				if key2 == key:
					continue
				if pop_num[key2] > 0:
					unique=0
			if unique == 1:
				pop_unique[key][line.split("\t")[1]]=line.split("\t")[0]
		shared=1
		for key in pop_num.keys():
			if pop_num[key]==0:
				shared=0
		if shared == 1:
			pop_shared[line.split("\t")[1]]=line.split("\t")[0]

with open (out_stat_file,'w')as out:
	out.write("Type\tName\tID\n")
	for key in pop_unique:
		for key2 in pop_unique[key]:
			out.write(key+"\t"+key2+"\t"+pop_unique[key][key2]+"\n")
	for key in pop_shared:
		out.write("Shared\t"+key+"\t"+pop_shared[key]+"\n")

def Write_gene(info_file,id_hash,out_file):
	genes={}
	with open(info_file) as lines:
		for line in lines:
			for key in id_hash.keys():
				if line.split("\t")[2]	== key and line.replace("\n","").split("\t")[6]!="NA":
					for gene in line.replace("\n","").split("\t")[6].split(","):
						genes[gene]=0
	with open(out_file,'w') as out:
		for gene in genes.keys():
			out.write(gene+"\n")

def Write_gff_gene(gff_file,id_hash,out_file):
	genes={}
	with open(gff_file) as lines:
		for line in lines:
			for key in id_hash.keys():
				if line.split("\t")[0]  == key and line.split("\t")[2]  == 'mRNA':
					gene_id=re.findall(";ref-gene=(.*?);",line)[0]+".1"
					genes[gene_id]=0
	with open(out_file,'w') as out:
		for gene in genes.keys():
			out.write(gene+"\n")

for key in pop_unique:
	out_file=out_gene_pre+"_body_inserted_"+key+"_gene"
	Write_gene(ins_gene_file,pop_unique[key],out_file)
	out_file=out_gene_pre+"_upstream_inserted_"+key+"_gene"
	Write_gene(upstream_gene_file,pop_unique[key],out_file)
	out_file=out_gene_pre+"_annotated_"+key+"_gene"
	Write_gff_gene(gff_file,pop_unique[key],out_file)

out_file=out_gene_pre+"_body_inserted_shared_gene"
Write_gene(ins_gene_file,pop_shared,out_file)
out_file=out_gene_pre+"_upstream_inserted_shared_gene"
Write_gene(upstream_gene_file,pop_shared,out_file)
out_file=out_gene_pre+"_annotated_shared_gene"
Write_gff_gene(gff_file,pop_shared,out_file)
