form_otu <- function(line){
	unlist(strplit(line, "\t"))[-1]
}

cvsearch_to_list <- function(clustered_file_name){
	clustered_file_name <- "data/he/he_1.0_01.vclosed/vsearch/ref_clustered.uc"
	clustered_data <- scan(clustered_file_name, what=character(), sep='\n', quiet=T)



}
