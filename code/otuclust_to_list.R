# the otuclust format puts otus on separate rows and the sequences within each
# otu on the same line separated by tabs

otuclust_to_list <- function(otuclust_file_name){
	otuclust_data <- scan(otuclust_file_name, what="", sep="\n", quiet=TRUE)
	otuclust_data <- gsub('\t', ',', otuclust_data)
	n_otus <- length(otuclust_data)
	list_data <- paste("userLabel", n_otus, otuclust_data, collapse='\t')
	list_file_name <- gsub("\\.clust", ".list", otuclust_file_name)
	write(list_data, list_file_name)
}
