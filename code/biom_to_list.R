library("jsonlite")

biom_to_list <- function(biom_file_name){
	biom_file <- scan(biom_file_name, what="", sep="\n", quiet=TRUE)
	biom_json <- fromJSON(biom_file)

	n_otus <- biom_json$shape[1]
	n_seqs <- biom_json$shape[2]
	seq_names <- biom_json$columns[["id"]]

	biom_json$data <- biom_json$data + 1
	otu_assignments <- aggregate(seq_names[biom_json$data[,2]],by=list(biom_json$data[,1]), function(x){paste(x, collapse=",")})$x

	list_data <- paste(c("userLabel", n_otus, otu_assignments), collapse="\t")
	
	list_file_name <- gsub("/[^\\/]*$", ".list", biom_file_name)

	write(list_data, list_file_name)
}

