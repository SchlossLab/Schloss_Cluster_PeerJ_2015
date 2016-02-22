fasta_file <- 'data/staggered/staggered.fasta'

get_seq_names <- function(fasta_file){
	fasta_data <- scan(fasta_file, what=character(), sep='\n', quiet=T)
	is_seq_name <- grepl("^>", fasta_data)
	gsub('>', '', fasta_data[is_seq_name])
}

make_list <- function(name, freq){
	redundant <- paste(name, (1:freq), sep="_")
	redundant[1] <- name
	redundant <- paste(redundant, collapse=",")
	paste(name, redundant, sep='\t')
}

even <- function(fasta_file, n_seqs=100){
	seq_names <- get_seq_names(fasta_file)
	names_data <- sapply(seq_names, make_list, freq=n_seqs)
	names_file <- gsub('fasta', 'names', fasta_file)
	write(names_data, names_file)
}

staggered <- function(fasta_file, max_n_seqs=200){
	set.seed(1)
	seq_names <- get_seq_names(fasta_file)
	freqs <- floor(runif(length(seq_names), 1, max_n_seqs))
	names_data <- mapply(make_list, seq_names, freqs)
	names_file <- gsub('fasta', 'names', fasta_file)
	write(names_data, names_file)
}
