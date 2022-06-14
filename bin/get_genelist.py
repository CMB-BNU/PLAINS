import sys

anno_list=sys.argv[1]

with open (anno_list) as lines:
	for line in lines:
		if line.split("\t")[6] != "NA\n":
			for gene in line.replace("\n","").split("\t")[6].split(","):
				print(gene)
