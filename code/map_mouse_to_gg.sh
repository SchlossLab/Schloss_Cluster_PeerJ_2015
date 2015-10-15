# Inputs:
#	data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta
#	data/gg_13_8/97_otus.align
#	data/references/silva.bact_archaea.align
#
#	code/map_to_reference.R
#	code/distance.cpp
#
# Output:
#	data/rand_ref/miseq.ref.mapping

mothur "#align.seqs(fasta=data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta, reference=data/references/silva.bact_archaea.align, outputdir=data/rand_ref, processors=4); screen.seqs(fasta=data/gg_13_8/97_otus.align, start=13862, end=23443, outputdir=data/rand_ref, processors=8); filter.seqs(fasta=data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.align-data/rand_ref/97_otus.good.align, vertical=T, trump=., processors=8);"

R -e "source('code/map_to_reference.R')"

rm data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.align
rm data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.align.report
rm data/rand_ref/97_otus.good.align
rm data/rand_ref/97_otus.bad.accnos
rm data/rand_ref/miseq97_otus.filter
rm data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.filter.fasta
rm data/rand_ref/97_otus.good.filter.fasta
