library(plyr)

extract_opt_swarm <- function(opt_file_name="data/he/he.swarm.opt.sensspec"){
	pool_file <- gsub("opt\\.", "pool_", opt_file_name)

	opt_file <- read.table(file=opt_file_name, header=T)
	opt_data <- ddply(.data=opt_file,
						.variables="label",
						.fun=function(x)x[which.max(x$mcc),])

	fraction <- gsub(".*_(\\d\\.\\d)_.*", "\\1", opt_data$label)
	replicate <- gsub(".*_(\\d\\d)\\..*", "\\1", opt_data$label)
	label <- "userLabel"

	pool <- data.frame(fraction, replicate, label, opt_data[,-1])

	write.table(file=pool_file, pool, quote=F, row.names=F, sep='\t')
}
