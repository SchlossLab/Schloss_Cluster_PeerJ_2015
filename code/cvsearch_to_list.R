cvsearch_to_list <- function(unique_file_name, clustered_file_name){

	uniqued <- read.table(file=unique_file_name, stringsAsFactors=FALSE)

	names_first_column <- uniqued[uniqued$V1=="S", "V9"]
	names_second_column <- names_first_column

	hits <- uniqued[uniqued$V1=="H", ]

	for(i in 0:(length(names_first_column)-1)){
		dups <- paste(hits[hits$V2==i, "V9"], collapse=",")
		names_second_column[i+1] <- paste(names_second_column[i+1], dups, sep=",")
	}
	names_second_column <- gsub(",$", "", names_second_column)
	names(names_second_column) <- names_first_column

	clustered <- read.table(file=clustered_file_name, stringsAsFactors=FALSE)
	unique_sequence <- gsub(";size=.*", "", clustered$V9)
	duplicate_sequences <- names_second_column[unique_sequence]

	ref_sequence <- as.character(clustered$V10)

	otu_list <- character()

	for(i in 1:length(ref_sequence)){
		if(is.na(otu_list[ref_sequence[i]])){
			otu_list[ref_sequence[i]] <- duplicate_sequences[i]
		} else {
			otu_list[ref_sequence[i]] <- paste(otu_list[ref_sequence[i]], duplicate_sequences[i], sep=',')
		}
	}

	list_file_data <- paste(c("userLabel", length(otu_list), otu_list), collapse='\t')
	list_file_name <- gsub("vclosed/vsearch/abundance_sorted.uc", "cvsearch.list", unique_file_name)
	list_file_name <- gsub("ng.", "", list_file_name)
	write(list_file_data, list_file_name)
}
