v4_dist <- read.table(file="data/gg_13_8/gg_13_8_97.v4_ref.unique.dist")
n_small_v4_dist <- sum(v4_dist$V3<=0.03)

v19_dist <- read.table(file="data/gg_13_8/gg_13_8_97.v19_ref.unique.dist")
n_small_v19_dist <- sum(v19_dist$V3<=0.03)

write.table(file="data/gg_13_8/gg_13_8_97.small_dist.count", c(v4=n_small_v4_dist, v19=n_small_v19_dist), col.names=F, quote=F)
