# Using the LOG options in NINJA-OPS creates a ninja_pass.log file where the
# first column is the sequence name and the second column is the references
# sequence that it mapped to. We need to convert this to a list file...

library(dplyr)

ninja_to_list <- function(folder_name){

	folder_name <- "even_1.0_01.ng.ninja"
	input_file_name <- paste0(folder_name, '/ninja_pass.log')
	output_file_name <- paste0(folder_name, '.list')
	output_file_name <- gsub("ng.", "", output_file_name)

	mapping <- read.table(file=input_file_name, stringsAsFactors=FALSE)
	mapping$V2 <- as.character(mapping$V2)

	list_data <- mapping %>% group_by(factor(V2)) %>% summarise(otu=paste(V1, collapse=','))

	list_output <- paste(c("userLabel", length(list_data), list_data), collapse='\t')

	write(list_output, output_file_name)

}
