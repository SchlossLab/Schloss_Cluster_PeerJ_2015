# the sumaclust format puts otus on separate rows and the sequences within each
# otu on the same line separated by tabs. the representative sequence name is
# repeated in the first two columns

sumaclust_to_list <- function(sumaclust_file_name){
	sumaclust_data <- scan(sumaclust_file_name, what="", sep="\n", quiet=TRUE)
	sumaclust_data <- gsub("^[^\t]\t", "", sumaclust_data)
	sumaclust_data <- gsub('\t', ',', sumaclust_data)
	n_otus <- length(sumaclust_data)
	list_data <- paste(c("userLabel", n_otus, sumaclust_data), collapse='\t')
	list_file_name <- gsub("\\.clust", ".list", sumaclust_file_name)
	list_file_name <- gsub("\\.ng", "", list_file_name)
	write(list_data, list_file_name)
}
