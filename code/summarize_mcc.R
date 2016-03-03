summarize_mcc <- function(dataset){

	methods <- c("an", "fn", "nn", "agc", "dgc",
				"vagc", "vdgc", "swarm", "sumaclust", "otuclust",
				"closed", "ninja", "sortmerna", "cvsearch", "open")

	output_file_name <- paste0("data/process/", dataset, ".mcc.summary")
	write(x="mean\tlci\tuci\tfraction\tmethod", file=output_file_name)

	for(m in methods){
		file_name <- paste0("data/", dataset, "/", dataset, ".", m, ".pool_sensspec")
		mcc_data <-read.table(file=file_name, header=T)
		mcc_stats_table <- aggregate(mcc_data$mcc, by=list(mcc_data$fraction), function(x)c(mean=mean(x), quantile(x, probs=c(0.025, 0.975))))

		mcc_summary <- cbind(mcc_stats_table$x, mcc_stats_table$Group, rep(m, nrow(mcc_stats_table)))
		write.table(file=output_file_name, mcc_summary, col.names=F, row.names=F, append=T, quote=F)
	}

}
