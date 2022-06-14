import sys
list_file=sys.argv[1]
fasta_path=sys.argv[2]
bed_path=sys.argv[3]
out_file=sys.argv[4]

inds=[]

def Read_fasta(filename):
	with open(filename,'r') as fr:
		seq={}
		aseq=''
		geneid=''
		for line in fr:
			if line.startswith('>'):
				if aseq != ''and geneid != '':
					seq[geneid]=aseq
				geneid=line.replace('>','').split()[0]
				aseq=''
			else:
				aseq+=line.replace("\n",'').upper()
		seq[geneid]=aseq
	return seq

def Read_bed(filename,list_h):
	with open(filename,'r') as lines:
		for line in lines:
			list_h[line.split("\t")[3].split(":")[1]]=""

def write_fasta(seqhash,filename):
	with open (filename,'w') as out:
		for each_id in seqhash.keys():
			i=0
			seq=seqhash[each_id]
			out.write('>'+each_id+'\n')
			while i<len(seq):
				if i+80 <= len(seq):
					out.write(seq[i:i+80]+'\n')
				else:
					out.write(seq[i:len(seq)]+'\n')
				i+=80
	
with open (list_file) as lines:
	for line in lines:
		inds.append(line.replace("\n",""))

out_seqs={}

for ind in inds:
	fasta_file=fasta_path+"/"+ind+".fasta"
	left_bed_file=bed_path+"/"+ind+".left.bed"
	right_bed_file=bed_path+"/"+ind+".right.bed"
	all_seqs=Read_fasta(fasta_file)
	mapped_seqs={}
	Read_bed(left_bed_file,mapped_seqs)
	Read_bed(right_bed_file,mapped_seqs)
	for seqid in all_seqs.keys():
		if seqid not in mapped_seqs.keys():
			new_id= ind +":"+seqid
			out_seqs[new_id]=all_seqs[seqid]

write_fasta(out_seqs,out_file)
