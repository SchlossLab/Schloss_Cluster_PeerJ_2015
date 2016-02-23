# the sortmrna format puts otus on separate rows and the sequences within each
# otu on the same line separated by tabs. the reference sequence name is in the
# first column and can be ignored.


#he_1.0_01_otus.txt

sortmerna_to_list <- function(sortmerna_folder_name){
	stub <- gsub(".sortmerna", "_otus.txt", sortmerna_folder_name)
	sortmerna_file <- paste0(sortmerna_folder_name, "/", stub)
	sortmerna_data <- scan(sortmerna_file, what="", sep="\n", quiet=TRUE)
	sortmerna_data <- gsub("^[^\t]*\t", "", sortmerna_data)
	sortmerna_data <- gsub('\t', ',', sortmerna_data)
	n_otus <- length(sortmerna_data)
	list_data <- paste(c("userLabel", n_otus, sortmerna_data), collapse='\t')
	list_file_name <- paste0(sortmerna_folder_name, ".list")
	list_file_name <- gsub("\\.ng", "", list_file_name)
	write(list_data, list_file_name)
}
