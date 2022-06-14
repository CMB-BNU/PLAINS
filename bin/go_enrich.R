#Library packages
library('optparse')
library('clusterProfiler')

#Gain parameters
option_list <- list(
	make_option(c("-g", "--gene"), type = "character", default = NULL,
		action = "store", help = "Gene list file"
	),
	make_option(c("-o", "--outprefix"), type = "character", default = 'out',
		action = "store", help = "Output prefix [default out]"
	),
	make_option(c("-q", "--qvalue"), type = "numeric", default = 1,
		action = "store", help = "qvalue cutoff [default 1]"
	),
	make_option(c("-a", "--go_annotation"), type = "character", 
                action = "store", 
		help = "GO annotation file"
	),
	make_option(c("-c", "--go_class"), type = "character",
		action = "store",
		help = "GO class file"
	)
)
opt = parse_args(OptionParser(option_list = option_list))

#Greate go_anno background
go_anno <- read.delim(opt$go_annotation,header=FALSE,stringsAsFactors= FALSE)
names(go_anno) <-c('gene_id', 'ID')
go_class <- read.delim(
	opt$go_class, 
	header=FALSE,stringsAsFactors = FALSE
)
names(go_class) <-c('ID', 'Description', 'Ontology')
go_anno <- merge(go_anno, go_class, by = 'ID',all.x = TRUE)

#Gene list
gene_select <- read.delim(opt$gene,header=FALSE,stringsAsFactors=FALSE)$V1

#GO enrichment
go_rich <- enricher(
	gene = gene_select,TERM2GENE = go_anno[c('ID', 'gene_id')],
	TERM2NAME = go_anno[c('ID', 'Description')],
	pvalueCutoff = 1,pAdjustMethod = 'BH',
	qvalueCutoff = opt$qvalue,  maxGSSize = 500
)

#Output
out_table=paste0(opt$outprefix,"_go.txt")
write.table(go_rich@result,file=out_table,sep="\t")
out_dot=paste0(opt$outprefix,"_dotplot.pdf")
out_bar=paste0(opt$outprefix,"_barplot.pdf")
pdf(out_dot)
dotplot(go_rich,showCategory=25,label_format=30,font.size = 6)
dev.off()
pdf(out_bar)
barplot(go_rich,showCategory=25,label_format=30,font.size = 6)
dev.off()
