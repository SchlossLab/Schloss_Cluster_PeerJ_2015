method <- c(u="usearch", v="vsearch", n="ninja", s="sortmerna")

summarize_closed_ref_sensspec <- function(df, file_name){

	data <- read.table(file=file_name, header=T)
	method <- gsub("data/rand_ref/closed_ref.(.*).sensspec", "\\1", file_name)

	sensspec_summary <- data.frame(method=method, t(apply(data, 2, mean)))

	if(is.null(df)){
		df <- sensspec_summary
	} else {
		df <- rbind(df, sensspec_summary)
	}

	return(df)
}

summarize_hits <- function(df, file_name){

	data <- read.table(file=file_name, header=F, row.names=1)
	m <- gsub(".*hits.(.*)closed.summary", "\\1", file_name)

	df[df$method==method[m], c("min_hits")] <- data["min", 1]
	df[df$method==method[m], c("mean_hits")] <- data["mean", 1]
	df[df$method==method[m], c("max_hits")] <- data["max", 1]

	df
}

sensspec <- NULL
sensspec <- summarize_closed_ref_sensspec(sensspec, "data/rand_ref/closed_ref.vsearch.sensspec")
sensspec <- summarize_closed_ref_sensspec(sensspec, "data/rand_ref/closed_ref.usearch.sensspec")
sensspec <- summarize_closed_ref_sensspec(sensspec, "data/rand_ref/closed_ref.sortmerna.sensspec")
sensspec <- summarize_closed_ref_sensspec(sensspec, "data/rand_ref/closed_ref.ninja.sensspec")

sensspec <- summarize_hits(sensspec, "data/rand_ref/hits.vclosed.summary")
sensspec <- summarize_hits(sensspec, "data/rand_ref/hits.uclosed.summary")
sensspec <- summarize_hits(sensspec, "data/rand_ref/hits.sclosed.summary")
sensspec <- summarize_hits(sensspec, "data/rand_ref/hits.nclosed.summary")

write.table(sensspec, file="data/process/closed_ref_sensspec.summary", quote=F,
		row.names=F, sep='\t')
