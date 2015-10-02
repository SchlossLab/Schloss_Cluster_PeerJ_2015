he_file <- "data/process/he.mcc.summary"
miseq_file <- "data/process/miseq.mcc.summary"

he_mcc <- read.table(file=he_file, header=T)
miseq_mcc <- read.table(file=miseq_file, header=T)

methods <- c("an", "agc", "vagc", "dgc", "vdgc")
he_mcc <- he_mcc[he_mcc$method %in% methods,]
miseq_mcc <- miseq_mcc[miseq_mcc$method %in% methods,]

pdf("results/figures/figure_4.pdf", width=4.5, height=3)
par(mar=c(4, 5, 0.5, 0.5))

plot(NA, xlim=c(0.5,11.5), ylim=c(0,1), axes=F, ylab="MCC value", xlab="")

for(i in 1:length(methods)){
	row <- he_mcc[he_mcc$method==methods[i] & he_mcc$fraction==1,]
	arrows(x0=i, y0=row$mean, y1=row$uci+1e-4, angle=90, length=0.1)
	arrows(x0=i, y0=row$mean, y1=row$lci-1e-4, angle=90, length=0.1)
	points(i, row$mean, pch=19)
}

for(i in 1:length(methods)){
	row <- miseq_mcc[he_mcc$method==methods[i] & miseq_mcc$fraction==1,]
	arrows(x0=i+6, y0=row$mean, y1=row$uci+(1e-3), angle=90, length=0.1)
	arrows(x0=i+6, y0=row$mean, y1=row$lci-(1e-3), angle=90, length=0.1)
	points(i+6, row$mean, pch=19)
}

axis(1, at=c(1:5, 7:11), label=c("AL", "U", "V", "U", "V", "AL", "U", "V", "U", "V"), cex.axis=0.9)
axis(2, las=2)
box()
mtext(side=1, line=2, at=2.5, "AGC")
mtext(side=1, line=2, at=4.5, "DGC")

mtext(side=1, line=2, at=8.5, "AGC")
mtext(side=1, line=2, at=10.5, "DGC")
abline(v=6, col="gray")
text(x=3, y=0.9, label="Canadian soil")
text(x=9, y=0.9, label="Murine gut")
dev.off()
