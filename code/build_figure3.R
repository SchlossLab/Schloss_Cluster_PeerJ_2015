build_mcc_plot <- function(dataset, output_file_name, threshold=0.6){

	data <- read.table(file=paste0("data/process/", dataset, ".mcc.summary"), header=T, stringsAsFactors=F)

	methods <- c("fn", "nn", "an", "dgc", "agc", "closed", "open")
	n_methods <- length(methods)

	orig_methods <- data[data$method %in% methods,]

	pdf(file=output_file_name, width=7.5, height=4)
	layout(matrix(c(1,2), nrow=1), widths=c(4, 3.5))

	par(mar=c(5.5, 5, 0.5, 0.5))

	plot(NA, ylim=c(0,1), xlim=c(0.1,1), axes=F, ylab="", xlab="")
	clrs <- rainbow(n_methods)
	abline(v=threshold, col="gray", lwd=2)

	for(m in 1:n_methods){
		subset <- orig_methods[orig_methods$method==methods[m],]
		points(subset$mean~subset$fraction, type="l", col=clrs[m], lwd=2)
	}
	axis(1)
	axis(2, las=1)
	box()

	text(x=0.12, y=0.98, label="A", cex=1.5, font=2)

	title(ylab="MCC value relative to\ndistance matrix")
	title(xlab="Fraction of dataset used")




	par(mar=c(5.5, 0.5, 0.5, 0.5))

	sixty <- orig_methods[orig_methods$fraction==threshold,]
	sixty$method <- factor(sixty$method, levels=methods)

	plot(NA, ylim=c(0.0,1), xlim=c(0.75,7.25), axes=F, ylab="", xlab="")

	for(m in 1:n_methods){
		points(x=m, y=sixty[sixty$method==methods[m],"mean"], pch=19, col=clrs[m])

		arrows(x0=m, y0=sixty[sixty$method==methods[m],"mean"], x1=m, y1=sixty[sixty$method==methods[m],"lci"], lwd=2, angle=90, length=0.1, col=clrs[m])
		arrows(x0=m, y0=sixty[sixty$method==methods[m],"mean"], x1=m, y1=sixty[sixty$method==methods[m],"uci"], lwd=2, angle=90, length=0.1, col=clrs[m])
	}

	axis(1, at=1:7, label=c("CL", "SL", "AL", "DGC", "AGC", "Closed-ref", "Open-ref"), las=2)
	#axis(2, las=1)
	box()

	text(x=0.87, y=0.98, label="B", cex=1.5, font=2)

	dev.off()

}
