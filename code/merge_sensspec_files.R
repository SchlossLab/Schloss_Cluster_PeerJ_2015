# this script is used to merge the sensspec files from each of the clustering
# algorithms


# this function gets the appropriate line from the sensspec file and
# concatenates the fraction and replicate number to the front of the data
get_line <- function(file_name){
	all_lines <- scan(file_name, what="", sep="\n", quiet=TRUE)
	
	to_match <- c("0.03", "userLabel")
	line <- all_lines[grepl(paste(to_match, collapse="|"), all_lines)]
	
	fraction <- gsub(".*_(\\d.\\d*)_\\d\\d*.*", "\\1", file_name)
	replicate <- gsub(".*_\\d.\\d*_(\\d\\d*).*", "\\1", file_name)
	
	paste(fraction, replicate, line, sep="\t")
}


# here we do the actual merging
merge_sens_spec <- function(folder="data/he", pattern, output){	
	sensspec_files <- list.files(folder, pattern, full.names=TRUE)
	
	write("fraction\treplicate\tlabel\tcutoff\ttp\ttn\tfp\tfn\tsensitivity\tspecificity\tppv\tnpv\tfdr\taccuracy\tmcc\tf1score", output)
	write(sapply(sensspec_files, get_line), output, append=TRUE)
}

