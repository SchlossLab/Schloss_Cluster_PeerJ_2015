split_seq_names <- function(long_name){
	unlist(strsplit(long_name, split=","))
}

count_tax <- function(seq_names, taxa){
	length(unique(taxa[seq_names,]))
}

unique_file <- read.table(file="data/gg_13_8/gg_13_8_97.v4_ref.names", stringsAsFactors=FALSE)
tax_file <- read.table(file="~/venv/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/taxonomy/97_otu_taxonomy.txt", sep="\t", row.names=1, stringsAsFactors=FALSE)

dups <- unique_file[grep(",", unique_file$V2),]
split_dups <- lapply(dups$V2, split_seq_names)
n_dups <- sapply(split_dups, length)
n_taxa <- sapply(split_dups, count_tax, tax_file)

combined <- cbind(dups$V1, n_dups = n_dups, n_taxa = n_taxa)
write.table(combined, file="data/gg_13_8/duplicate.analysis", quote=F, row.names=F, col.names=F)

