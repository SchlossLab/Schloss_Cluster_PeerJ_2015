gg_summary <- read.table(file="data/gg_13_8/gg_13_8_97.v19.summary", header=T)
n_v4_overlap <- sum(gg_summary$start <= 3967 & gg_summary$end >= 6116)
n_v9_overlap <- sum(gg_summary$start <= 10179 & gg_summary$end >= 10683)
n_v19_total <- nrow(gg_summary)

write.table(file="data/gg_13_8/gg_13_8_97.overlap.count", c(v4=n_v4_overlap, v9=n_v9_overlap, v19=n_v19_total), col.names=F, quote=F)
