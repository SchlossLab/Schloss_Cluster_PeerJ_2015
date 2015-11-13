usearch_counts <- read.table(file="data/rand_ref/hits.uclosed.counts")
usearch_original <- usearch_counts[nrow(usearch_counts), 2]
usearch_counts <-  usearch_counts[-nrow(usearch_counts), 2]

vsearch_counts <- read.table(file="data/rand_ref/hits.vclosed.counts")
vsearch_original <- vsearch_counts[nrow(vsearch_counts), 2]
vsearch_counts <-  vsearch_counts[-nrow(vsearch_counts), 2]
stopifnot(sd(vsearch_counts) == 0, mean(vsearch_counts) == vsearch_original)


expected_counts <- nrow(read.table(file="data/rand_ref/closed_ref.redundancy.analysis", header=T))


pdf(file="results/figures/figure_5.pdf", width=4, height=4)
par(mar=c(4,4,0.5,0.5), cex=0.8)

hist(usearch_counts, xlim=c(27600, 28350), ylim=c(0,10), breaks=4, main="", xlab="", axes=F, col="gray")
arrows(x0=usearch_original, y0=2, y1=0, length=0.10)
text(x=usearch_original, y=3.0, label="Number of hits\nusing USEARCH\nwith default\nordering", cex=0.8)

arrows(x0=vsearch_original, y0=1, y1=0, length=0.10)
text(x=vsearch_original, y=1.5, label="Number of hits\nusing VSEARCH", cex=0.8)

arrows(x0=expected_counts, y0=0.75, y1=0, length=0.10)
text(x=expected_counts, y=1.5, label="Expected\nnumber\nof hits", cex=0.8)


text(x=median(usearch_counts), y=8.9, label="Number of hits\nusing USEARCH\nwith randomized\nordering", cex=0.8)


polygon(x=c(0, 0, 28350, 28350),y=c(0, 10, 10, 0))
title(xlab="Number of Sequences that\nMapped to the Reference", line=3)
axis(1, at=seq(27600,28300,100), label=format(seq(27600,28300,100), big.mark=','), pos=0)
axis(2, las=2)

dev.off()
