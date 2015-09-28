summarize_mcc_ref <- function(dataset){
	methods <- c("an", "fn", "nn", "agc", "dgc", "closed", "open", "swarm", "vagc", "vdgc")

	output_file_name <- paste0("data/process/", dataset, ".mcc_ref.summary")
	write(x="mean\tlci\tuci\tfraction\tmethod", file=output_file_name)

	for(m in methods){
		file_name <- paste0("data/", dataset, "/", dataset, ".", m, ".ref_mcc")
		ref_mcc <-read.table(file=file_name, header=T)
		stats_mcc <- data.frame(t(apply(ref_mcc[,1:5], 2, function(x)c(mean(x), quantile(x, probs=c(0.025, 0.975))))))
		stats_mcc$fraction <- gsub("X", "", rownames(stats_mcc))
		stats_mcc$method <- rep(m, nrow(stats_mcc))
		write.table(file=output_file_name, stats_mcc, col.names=F, row.names=F, append=T, quote=F)
	}
}

