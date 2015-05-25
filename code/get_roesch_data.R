library(rentrez)
NCBI_data <- entrez_link(dbfrom = "pubmed", id = "18043639", db = "all")
n_popsets <- length(NCBI_data$pubmed_popset)

fetched_data <- character()
for(i in 1:n_popsets){
    fetched_data[i] <- entrez_fetch(db = "popset", rettype = 'fasta', id = NCBI_data$pubmed_popset[i])
}

full_fasta_file <- paste(fetched_data, collapse="")
full_fasta_file <- gsub("\n\n", "\n", full_fasta_file)
split_fasta_file <- unlist(strsplit(full_fasta_file, ">"))[-1]

seq_ids <- sub("^gi\\|\\d*\\|gb\\|EF(\\d*).1\\|.*", "\\1", split_fasta_file)
seq_ids <- as.numeric(seq_ids)

seq_bases <- sub("^.*partial sequence\n", "\\1", split_fasta_file)
seq_bases <- gsub("\\n", "", seq_bases)

used_ids <- 308591:361836

keep_sequences <- seq_ids %in% used_ids

keep_ids <- seq_ids[keep_sequences]
keep_bases <- seq_bases[keep_sequences]
keep_fasta <- paste0(">EF", keep_ids, "\n", keep_bases)

write(keep_fasta, "data/raw/canada_soil.fasta")

