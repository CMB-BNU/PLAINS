import sys

bed_file1=sys.argv[1]
bed_file2=sys.argv[2]
gt_file=sys.argv[3]
out_file=sys.argv[4]

def Read_bed(filename):
	lists=[]
	with open (filename) as lines:
		for line in lines:
			lists.append(line.replace("\n",""))
	return lists

left_beds=Read_bed(bed_file1)
right_beds=Read_bed(bed_file2)

id_name={}
with open(gt_file) as lines:
	for line in lines:
		if line[0]=="I":
			continue
		id_name[line.split("\t")[0]]=line.split("\t")[1]

output=[]
for contig_id in id_name.keys():
	name=id_name[contig_id]
	nt_name=name.split(":")[0]+":"+name.split(":")[1]
	for line in left_beds:
		if nt_name in line.split("\t")[3].split(","):
			loci=str(int(line.split("\t")[2])+1)
			chr_id=line.split("\t")[0]
	for line in right_beds:
		if nt_name in line.split("\t")[3].split(","):
			loci=str(int(line.split("\t")[1])+1)
			chr_id=line.split("\t")[0]
	output.append(contig_id+"\t"+name+"\t"+chr_id+"\t"+loci+"\n")

with open(out_file,'w') as out:
	for line in output:
		out.write(line)
