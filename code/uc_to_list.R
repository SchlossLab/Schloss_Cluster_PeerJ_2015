uc_to_list <- function(unique_file_name, clustered_file_name){

	uniqued <- read.table(file=unique_file_name, stringsAsFactors=FALSE)

	names_first_column <- uniqued[uniqued$V1=="S", "V9"]
	names_second_column <- names_first_column

	hits <- uniqued[uniqued$V1=="H", ]

	for(i in 0:(length(names_first_column)-1)){
		dups <- paste(hits[hits$V2==i, "V9"], collapse=",")
		names_second_column[i+1] <- paste(names_second_column[i+1], dups, sep=",")
	}
	names_second_column <- gsub(",$", "", names_second_column)


	clustered <- read.table(file=clustered_file_name, stringsAsFactors=FALSE)
	clustered$sequence <- 1:nrow(clustered)

	otus <- names_second_column[clustered[clustered$V1=="S", "sequence"]]
	hits <- clustered[clustered$V1=="H", ]

	for(i in 1:nrow(hits)){
		otus[hits[i,"V2"]+1] <- paste(otus[hits[i,"V2"]+1], names_second_column[hits[i,"sequence"]], sep=",") 
	}

	list_file_name <- gsub("clustered.uc", "list", clustered_file_name)
	list_data <- paste(otus, collapse="\t")
	list_data <- paste("userLabel", length(otus), list_data, sep="\t")
	write.table(x=list_data, file=list_file_name, quote=F, row.names=F, col.names=F, sep="\t")

}

