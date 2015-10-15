library(Rcpp)
sourceCpp("code/distance.cpp")

parse_fasta <- function(fasta_file_name){

	fasta_file <- scan(file=fasta_file_name, what="", sep='\n', quiet=T)

	n_lines <- length(fasta_file)
	sequences <- fasta_file[(1:n_lines) %% 2 == 0]
	names(sequences) <- gsub(">", "", fasta_file[(1:n_lines) %% 2 == 1])

	return(sequences)
}
seq_data <- parse_fasta("data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.filter.fasta")
ref_data <- parse_fasta("data/rand_ref/97_otus.good.filter.fasta")

mapping_results <- lapply(seq_data, map_to_reference, references=ref_data)

duplicates <- sapply(mapping_results, function(x){paste(names(ref_data)[x[[2]]], collapse=",")})
distances <- sapply(mapping_results, function(x){as.numeric(x[[1]])})

write.table(file="data/rand_ref/miseq.ref.mapping", x=cbind(names(seq_data), distance=distances, references=duplicates), row.names=F, quote=F, sep='\t')
