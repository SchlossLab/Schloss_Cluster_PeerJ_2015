library("ggplot2")
library("plyr")

pool_summaries <- function(df, dataset){
	summary_file_name <- paste0("data/process/", dataset, ".mcc.summary")

	data <- read.table(file=summary_file_name, header=T)
	data <- data[data$fraction == 1.0,]
	data$dataset <- dataset

	if(is.null(df)){
		df <- data
	} else {
		df <- rbind(df, data)
	}
	return(df)
}

is_denovo <- function(method){
	method %in% c("an", "nn", "fn", "agc", "dgc", "vagc", "vdgc", "swarm",
								"sumaclust", "otuclust")
}

pooled_data <- NULL
pooled_data <- pool_summaries(pooled_data, "he")
pooled_data <- pool_summaries(pooled_data, "miseq")
pooled_data <- pool_summaries(pooled_data, "even")
pooled_data <- pool_summaries(pooled_data, "staggered")

ordering <- daply(
	.data = pooled_data[is_denovo(pooled_data$method),],
	.variables = "method",
	.fun = function(x) mean(x$mean)
)
ordering <- ordering[!is.na(ordering)]
de_novo_labels <- names(ordering)[order(ordering, decreasing=TRUE)]

ordering <- daply(
	.data = pooled_data[!is_denovo(pooled_data$method),],
	.variables = "method",
	.fun = function(x) mean(x$mean)
)
ordering <- ordering[!is.na(ordering)]
reference_labels <- names(ordering)[order(ordering, decreasing=TRUE)]

pooled_data$method <- factor(pooled_data$method, levels = c(de_novo_labels,reference_labels))

pretty_methods <- c(an = "AN", sumaclust = "Sumaclust", vdgc="V-DGC",
										vagc="V-AGC", dgc = "U-DGC",
										agc = "U-AGC", fn  = "FN", otuclust = "OTUCLUST",
										swarm = "Swarm",     nn = "NN", cvsearch="V-Closed",
										sortmerna = "SortMeRNA", open = "Open",
										closed = "U-Closed", ninja = "NINJA-OPS")

ggplot(pooled_data, aes(method, mean, col=dataset, shape=dataset)) +

	geom_rect(aes(xmin = -Inf, ymin = 0.9, xmax= Inf, ymax = Inf),
					col="lightgray", fill="lightgray") +
	geom_text(aes(x = 5.5, y = 0.98, label = "De novo"), size = 4,
					color="black", fontface="plain") +
	geom_text(aes(x = 13.00, y = 0.98, label = "Reference-based"), size = 4,
	 				color="black", fontface="plain") +
	geom_segment(aes( x=10.5, xend=10.5, y=-Inf, yend =Inf), color="black") +

	geom_point(position = position_dodge(0.5), size=2) +
	coord_cartesian(ylim=c(0,1)) +
	ylab("Mean Matthew's\nCorrelation Coefficient") +
	xlab(NULL) +
	scale_color_discrete(breaks=c("he", "miseq", "even", "staggered"),
						labels=c("Soil", "Mouse", "Even", "Staggered"))+
	scale_shape_manual(breaks=c("he", "miseq", "even", "staggered"),
						labels=c("Soil", "Mouse", "Even", "Staggered"),
						guide=guide_legend(override.aes=aes(size=2)),
						values = c(15, 16, 17, 18))+
	scale_x_discrete(breaks=levels(pooled_data$method),
					labels=pretty_methods[levels(pooled_data$method)]) +
	theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, size=8),
		axis.title=element_text(size=10),
		panel.grid.major.y = element_blank(),
		panel.grid.minor.y = element_blank(),
		panel.grid.major.x = element_line(colour = "gray",size=0.5),

		legend.title=element_blank(),
		legend.position = c(0.085, 0.3),
		legend.text = element_text(size = 8),
		legend.key.height=unit(0.7,"line"),
		legend.key = element_rect(fill = NA),
		legend.margin = unit(0,"line"),

		panel.border = element_rect(color = "black", fill=NA, size=1),
		panel.background = element_rect(fill=NA)
	)

ggsave("results/figures/all_method_comparison.pdf", width=6.5, height=3, units="in")
