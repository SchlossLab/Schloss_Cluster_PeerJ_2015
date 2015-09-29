summarize_rarefaction <- function(folder){
	methods <- c("an", "fn", "nn", "agc", "dgc", "closed", "open", "swarm")

	output_file_name <- paste0("data/process/", folder, ".rarefaction.summary")
	write(x="method\tfraction\tsobs\tsobs_lci\tsobs_uci\trarefied\trare_lci\trare_uci\tp_value", file=output_file_name)

	for(m in methods){
		print(m)
		file_name <- paste0("data/", folder, "/", folder, ".", m, ".rarefaction")
		rarefy <-read.table(file=file_name, header=T)
		fractions <- unique(rarefy$fraction)

		p <- numeric()
		rare_mean <- numeric()
		rare_lci <- numeric()
		rare_uci <- numeric()
		sobs_mean <- numeric()
		sobs_lci <- numeric()
		sobs_uci <- numeric()

		for(f in fractions){
			rarefy_sub <- rarefy[rarefy$f==f,]

			sobs_mean[as.character(f)] <- mean(rarefy_sub$sobs)
			sobs_lci[as.character(f)] <- quantile(rarefy_sub$sobs, prob=0.025)
			sobs_uci[as.character(f)] <- quantile(rarefy_sub$sobs, prob=0.975)

			rare_mean[as.character(f)] <- mean(rarefy_sub$rarefied)
			rare_lci[as.character(f)] <- quantile(rarefy_sub$rarefied, prob=0.025)
			rare_uci[as.character(f)] <- quantile(rarefy_sub$rarefied, prob=0.975)

			if(f != 1 && m != "closed"){
				p[as.character(f)] <- t.test(rarefy_sub$rarefied, rarefy_sub$sobs)$p.value
			} else {
				p[as.character(f)] <- NA
			}
		}
		output <- cbind(rep(m, length(fractions)), fractions, sobs_mean, sobs_lci, sobs_uci, rare_mean, rare_lci, rare_uci, p)
		write.table(file=output_file_name, output, col.names=F, row.names=F, append=T, quote=F, sep='\t')
	}
}
