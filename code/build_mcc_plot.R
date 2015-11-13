build_mcc_plots <- function(dataset, output_file_name){

	methods <- c("fn", "nn", "an", "dgc", "agc", "closed", "open", "swarm")
	n_methods <- length(methods)
	clrs <- c("brown", "red", "orange", rainbow(n_methods-1)[4:7], "black")

	my_pch <- c(15, 21, 16, 22, 17, 23, 18, 24)
	my_cex <-  c(2,2,2,2,2,2,3,2)
	data <- read.table(file=paste0("data/process/", dataset, ".mcc_ref.summary"), header=T, stringsAsFactors=F)

	orig_methods <- data[data$method %in% methods,]

	pdf(file=output_file_name, width=6.5, height=6.5)



	layout(matrix(c(1, 2, 3, 4, 5, 6, 0, 7, 0), nrow=3, byrow=T), widths=c(1.0,3.5, 3.5), heights=c(3.5,3.5,1.5))

	threshold <- 0.6

	par(mar=c(0,0,0,0))
	plot.new()
	text(x=0.3, y=0.5, label="Stability", cex=1.5, srt=90, xpd=TRUE)

	### A ###
	par(mar=c(0.5, 0.5, 0.5, 0.5))
	plot(NA, ylim=c(0,1), xlim=c(0.1,1), axes=F, xlab="", ylab="")

	abline(v=threshold, col="gray", lwd=2)

	for(m in 1:n_methods){
		subset <- orig_methods[orig_methods$method==methods[m],]
		points(subset$mean~subset$fraction, type="l", col=clrs[m], lwd=2)
		points(0.2, subset$mean[1], pch=my_pch[m], col=clrs[m], cex=my_cex[m], bg="white")
	}
	axis(1, at=seq(0.2,1.0,0.2), labels=rep("", 5))
	axis(2, las=1, cex.axis=1.5)
	box()

	text(x=0.12, y=0.98, label="A", cex=2.5, font=2)

	#title(xlab="Fraction of dataset used")

	### B ###
	par(mar=c(0.5, 0.5, 0.5, 0.5))

	sixty <- orig_methods[orig_methods$fraction==threshold,]
	sixty$method <- factor(sixty$method, levels=methods)
	sixty[sixty$method=="closed", c("lci", "uci")] <- c(0.999, 1.001)
	plot(NA, ylim=c(0.0,1), xlim=c(0.75,n_methods+0.25), axes=F, ylab="", xlab="")

	for(m in 1:n_methods){

		arrows(x0=m, y0=sixty[sixty$method==methods[m],"mean"], x1=m, y1=sixty[sixty$method==methods[m],"lci"]-1e-3, lwd=2, angle=90, length=0.1, col=clrs[m])
		arrows(x0=m, y0=sixty[sixty$method==methods[m],"mean"], x1=m, y1=sixty[sixty$method==methods[m],"uci"]+1e-3, lwd=2, angle=90, length=0.1, col=clrs[m])
		points(x=m, y=sixty[sixty$method==methods[m],"mean"], pch=my_pch[m], col=clrs[m], cex=my_cex[m], bg="white")

	}

	axis(1, at=1:n_methods, labels=rep("", n_methods))
	axis(2, at=seq(0.2,1.0,0.2), labels=rep("", 5))

	box()

	text(x=0.87, y=0.98, label="B", cex=2.5, font=2)


	data <- read.table(file=paste0("data/process/", dataset, ".mcc.summary"), header=T, stringsAsFactors=F)
	orig_methods <- data[data$method %in% methods,]

	swarm_data <- read.table(file=paste0("data/", dataset, "/", dataset, ".swarm.opt.sensspec"), header=T, stringsAsFactors=F)
	opt_swarm_data <- do.call(rbind, lapply(split(swarm_data, swarm_data$label), function(chunk) chunk[which.max(chunk$mcc),c("cutoff", "mcc")]))
	fraction <- gsub(".*_(\\d.\\d)_.*", "\\1", rownames(opt_swarm_data))
	swarm_mcc_by_fraction <- aggregate(opt_swarm_data, by=list(fraction), function(x)c(mean(x), range(x)))

	threshold <- 1.0

	par(mar=c(0,0,0,0))
	plot.new()
	text(x=0.3, y=0.5, label="Quality", cex=1.5, srt=90, xpd=TRUE)

	### C ###
	par(mar=c(0.5, 0.5, 0.5, 0.5))

	plot(NA, ylim=c(0,1), xlim=c(0.1,1), axes=F, ylab="", xlab="")

	abline(v=threshold, col="gray", lwd=2)

	for(m in 1:n_methods){
		subset <- orig_methods[orig_methods$method==methods[m],]
		points(subset$mean~subset$fraction, type="l", col=clrs[m], lwd=2)
		points(0.2, subset$mean[1], pch=my_pch[m], col=clrs[m], cex=my_cex[m], bg="white")

	}
	axis(1, cex.axis=1.5)
	axis(2, las=1, cex.axis=1.5)

	box()

	text(x=0.12, y=0.98, label="C", cex=2.5, font=2)





	### D ###
	par(mar=c(0.5, 0.5, 0.5, 0.5))

	sixty <- orig_methods[orig_methods$fraction==threshold,]
	sixty$method <- factor(sixty$method, levels=methods)

	plot(NA, ylim=c(0.0,1), xlim=c(0.75,n_methods + 0.25), axes=F, ylab="", xlab="")

	for(m in 1:n_methods){

		arrows(x0=m, y0=sixty[sixty$method==methods[m],"mean"], x1=m, y1=sixty[sixty$method==methods[m],"lci"]-1e-3, lwd=2, angle=90, length=0.1, col=clrs[m])
		arrows(x0=m, y0=sixty[sixty$method==methods[m],"mean"], x1=m, y1=sixty[sixty$method==methods[m],"uci"]+1e-3, lwd=2, angle=90, length=0.1, col=clrs[m])
		points(x=m, y=sixty[sixty$method==methods[m],"mean"], pch=my_pch[m], col=clrs[m], cex=my_cex[m], bg="white")
	}

	axis(1, at=1:n_methods, label=c("CL", "SL", "AL", "DGC", "AGC", "Closed-ref", "Open-ref", "Swarm"), las=2, cex.axis=1.5)
	axis(2, at=seq(0.2,1.0,0.2), labels=rep("", 5))
	box()

	text(x=0.87, y=0.98, label="D", cex=2.5, font=2)

	par(mar=c(0,0,0,0))
	plot.new()
	text(x=0.5, y=0.6, "Fraction of dataset used", cex=1.5)

	dev.off()

}
