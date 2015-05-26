read_fasta <- function(fasta_file_name){

    fasta_file <- scan(fasta_file_name, what="", sep="\n", quiet=TRUE)
    n_lines <- length(fasta_file)

    seq_names <- fasta_file[ 1:n_lines %% 2 == 1 ]
    seq_bases <- fasta_file[ 1:n_lines %% 2 == 0 ]
    paste0(seq_names, "\n", seq_bases)
    
}

get_subset <- function(sequences, fraction){

    n_seqs <- length(sequences)
    seq_indices <- sample(1:n_seqs, floor(fraction*n_seqs))
    sequences[seq_indices]

}


print_sequences <- function(stub, fraction, rep, sequences){
    
    file_name <- paste0(stub, "_", format(fraction, 1, nsmall=1), "_", rep, ".fasta")
    write(sequences, file_name)

}



generate_indiv_samples <- function(fasta_file_name, stub, fraction, rep_id){

   full_sequence_set <- read_fasta(fasta_file_name)
   subset <- get_subset(sequences=full_sequence_set, fraction=fraction)
   print_sequences(stub, fraction, rep_id, subset)

}
