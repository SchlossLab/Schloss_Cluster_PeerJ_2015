count_table <- read.table(file="data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table", header=T, row.names=1)

n_groups <- ncol(count_table) - 1 # get rid of total number of sequences
n_miseq_seqs <- sum(count_table$total)
n_unique_miseq_seqs <- nrow(count_table)

write.table(file="data/miseq/miseq.seq.info", c(n_groups=n_groups, total_seqs=n_miseq_seqs, unique_seqs=n_unique_miseq_seqs), col.names=F, quote=F)
