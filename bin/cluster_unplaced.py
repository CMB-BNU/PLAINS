import sys

fasta_file=sys.argv[1]
coord_file=sys.argv[2]
out_file=sys.argv[3]

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

def Write_fasta(seqhash,filename):
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

seqs=Read_fasta(fasta_file)

with open (coord_file) as lines:
	for line in lines:
		iden=float(line.split("\t")[6])
		len1=int(line.split("\t")[7])
		len2=int(line.split("\t")[8])
		cov1=float(line.split("\t")[9])
		cov2=float(line.split("\t")[10])
		id1=line.split("\t")[11]
		id2=line.split("\t")[12]
		if id1 == id2:
			continue
		if iden >=0.98 and (cov1>=0.95 or cov2 >=0.95):
			if len1 >= len2 and id2 in seqs.keys():
				del seqs[id2]
			elif len1 < len2 and id1 in seqs.keys():
				del seqs[id1]

Write_fasta(seqs,out_file)
