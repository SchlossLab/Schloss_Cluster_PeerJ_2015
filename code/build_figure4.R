methods <- c("an", "agc", "vagc", "dgc", "vdgc")

pdf("results/figures/figure_4.pdf", width=4.5, height=3)
par(mar=c(3, 4, 0.5, 0.5))

plot(NA, xlim=c(0.5,11.5), ylim=c(0,1), axes=F, ylab="MCC value", xlab="")

he_mcc <- read.table(file="data/process/he.mcc.summary", header=T)
he_ref <- read.table(file="data/process/he.mcc_ref.summary", header=T)
he_mcc <- he_mcc[he_mcc$method %in% methods,]
he_ref <- he_ref[he_mcc$method %in% methods,]

for(i in 1:length(methods)){
	row <- he_mcc[he_mcc$method==methods[i] & he_mcc$fraction==1,]
	arrows(x0=i, y0=row$mean, y1=row$uci+1e-3, angle=90, length=0.1)
	arrows(x0=i, y0=row$mean, y1=row$lci-1e-3, angle=90, length=0.1)
	points(i, row$mean, pch=19)

	row <- he_ref[he_ref$method==methods[i] & he_ref$fraction==0.6,]
	arrows(x0=i, y0=row$mean, y1=row$uci+1e-3, angle=90, length=0.1)
	arrows(x0=i, y0=row$mean, y1=row$lci-1e-3, angle=90, length=0.1)
	points(i, row$mean, pch=21, bg="white")
}

miseq_mcc <- read.table(file="data/process/miseq.mcc.summary", header=T)
miseq_ref <- read.table(file="data/process/miseq.mcc_ref.summary", header=T)
miseq_mcc <- miseq_mcc[miseq_mcc$method %in% methods,]
miseq_ref <- miseq_ref[miseq_mcc$method %in% methods,]

for(i in 1:length(methods)){
	row <- miseq_mcc[he_mcc$method==methods[i] & miseq_mcc$fraction==1,]
	arrows(x0=i+6, y0=row$mean, y1=row$uci+1e-3, angle=90, length=0.1)
	arrows(x0=i+6, y0=row$mean, y1=row$lci-1e-3, angle=90, length=0.1)
	points(i+6, row$mean, pch=19)

	row <- miseq_ref[miseq_ref$method==methods[i] & miseq_ref$fraction==0.4,]
	arrows(x0=i+6, y0=row$mean, y1=row$uci+1e-3, angle=90, length=0.1)
	arrows(x0=i+6, y0=row$mean, y1=row$lci-1e-3, angle=90, length=0.1)
	points(i+6, row$mean, pch=21, bg="white")
}

legend(x=7.5, y=0.4, legend=c("Relative to full dataset", "Relative to distances"), pch=c(21,19), pt.cex=0.8, pt.bg=c("white", "black"), cex=0.6, bty="n")
axis(1, at=c(1:5, 7:11), label=c("AL", "U", "V", "U", "V", "AL", "U", "V", "U", "V"), cex.axis=0.9)
mtext(side=1, line=2, at=2.5, "AGC")
mtext(side=1, line=2, at=4.5, "DGC")
mtext(side=1, line=2, at=8.5, "AGC")
mtext(side=1, line=2, at=10.5, "DGC")

text(x=3, y=0.01, label="Canadian soil")
text(x=9, y=0.01, label="Murine gut")

abline(v=6, col="gray")
axis(2, las=2)
box()

dev.off()
