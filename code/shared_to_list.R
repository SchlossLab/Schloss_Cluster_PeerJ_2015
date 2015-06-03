shared_to_list <- function(shared_file_name){

	shared_file <- read.table(shared_file_name, header=TRUE, row.names=2)
	shared <- shared_file[,-c(1,2)]

	rabund <- apply(shared, 2, sum)
	o <- order(rabund, decreasing=TRUE)
	shared <- shared[,o]

	get_composition <- function(column){
		paste(rownames(shared)[which(shared[,column] > 0)], collapse=",")
	}

	n_otus <- ncol(shared)
	list_data <- paste(unlist(lapply(1:n_otus, get_composition)), collapse="\t")
	list_line <- paste("userLabel", n_otus, list_data, sep="\t")


	list_file_name <- gsub("/[^\\/]*$", ".list", shared_file_name)

	write(list_line, list_file_name)

}

