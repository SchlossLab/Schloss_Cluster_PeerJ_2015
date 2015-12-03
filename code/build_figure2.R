build_figure2 <- function(dataset, output_file_name, position='bottomright'){

	rare <- read.table(file=paste0("data/process/", dataset, ".rarefaction.summary"), header=T, stringsAsFactors=T)

	offset <- 0.1

	n_fractions <- length(levels(factor(rare$fraction)))

	methods <- c("fn", "nn", "an", "dgc", "agc", "closed", "open", "swarm")

	rare_methods <- rare[rare$method %in% methods,]

	n_methods <- length(methods)

	clrs <- rainbow(n_fractions)

	orig_par <- par()

	pch <- c(22,21,24,23,25)

	pdf(file=output_file_name, width=4, height=4)
	par(mar=c(5,5,0.5,0.5))
	plot(NA, xlim=c(0.8,length(methods)+0.2), ylim=c(0,max(rare_methods$rare_uci)), axes=F, xlab="", ylab="")
	par(cex=0.8)
	for(m in 1:n_methods){

		subset <- rare_methods[rare_methods$method==methods[m],]

	#	the 95% confidence intervals were smaller or similar in size to the cex=1 plotting symbol
	#	arrows(x0=m-offset, y0=subset[,"sobs"], y1=subset[,"sobs_lci"], col=clrs, length=0.05, angle=90)
	#	arrows(x0=m-offset, y0=subset[,"sobs"], y1=subset[,"sobs_uci"], col=clrs, length=0.05, angle=90)
		points(rep(m-offset, n_fractions), subset[,"sobs"], col=clrs, pch=pch, cex=1.0, bg=clrs)

	#	the 95% confidence intervals were smaller or similar in size to the cex=1 plotting symbol
	#	arrows(x0=m+offset, y0=subset[,"rarefied"], y1=subset[,"rare_lci"], col=clrs, length=0.05, angle=90)
	#	arrows(x0=m+offset, y0=subset[,"rarefied"], y1=subset[,"rare_uci"], col=clrs, length=0.05, angle=90)
		points(rep(m+offset, n_fractions), subset[,"rarefied"], col=clrs, pch=pch, cex=1.0)
	}

	method_labels <- c("CL", "SL", "AL", "DGC", "AGC", "Closed-ref", "Open-ref", "Swarm")
	axis(1, at=1:n_methods, label=method_labels, las=2)
	axis(2, las=2, at=seq(0,6000,1000), label=c("0", "1,000", "2,000", "3,000", "4,000", "5,000", "6,000"))
	box()

	title(ylab="Number of OTUs", line=3.5)

	pos <- legend(position, legend=c("20%", "40%", "60%", "80%", "100%"), pch=pch,
										col="white", cex=0.7, bty="n")
	points(x=rep(pos$text$x, times=2) - c(0.4,0.2),
	    	y=rep(pos$text$y, times=2),
	    	pch=cbind(pch,pch),
			bg=cbind(clrs, rep("white", 5)),
			col=clrs
			)


	par <- orig_par
	dev.off()
}
