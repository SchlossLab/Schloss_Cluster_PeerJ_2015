# Inputs:
#	data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta
#	data/gg_13_8/97_otus.align
#	data/references/silva.bact_archaea.align

mothur "#align.seqs(fasta=data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta, reference=data/references/silva.bact_archaea.align, outputdir=data/rand_ref, processors=4);
	filter.seqs(fasta=data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.align-data/gg_13_8/97_otus.align, vertical=T);
	classify.seqs(fasta=data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.filter.fasta,reference=data/rand_ref/97_otus.filter.fasta, taxonomy=data/references/97_otus.taxonomy, method=knn, numwanted=1, search=distance)"

rm data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.align
rm data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.align.report
rm data/rand_ref/miseq97_otus.filter
rm data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.filter.fasta
rm data/rand_ref/97_otus.filter.fasta
rm data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.filter.97_otus.knn.taxonomy
rm data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.filter.97_otus.knn.tax.summary

#keep data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.filter.97_otus.knn.match.dist
