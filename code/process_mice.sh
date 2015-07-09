#!/bin/bash

################################################################################
#
# process_mice.sh#
#
# Here we run the data/MISEQ/*metag/*.files through mothur like we would in a
# normal study to the point of generating the final reads that go into
# cluster.split
#
# Dependencies...
# * data/miseq/miseq.files
#
# Produces...
# * *.precluster.pick.pick.fasta
# * *.precluster.uchime.pick.pick.count_table
#
################################################################################

FILES_FILE=$1
MISEQ_PATH=$(echo $FILES_FILE | sed -E 's/(.*)\/[^\/]*/\1/')

mothur "#pcr.seqs(outputdir=$MISEQ_PATH, fasta=data/references/silva.bacteria.align, start=11894, end=25319, keepdots=F, processors=12)"
mv $MISEQ_PATH/silva.bacteria.pcr.align $MISEQ_PATH/silva.v4.align


mothur "#set.dir(output=$MISEQ_PATH);
	make.contigs(inputdir=$MISEQ_PATH, file=$FILES_FILE, processors=12);
	screen.seqs(fasta=current, group=current, maxambig=0, maxlength=275, maxhomop=8);
	unique.seqs();
	count.seqs(name=current, group=current);
	align.seqs(fasta=current, reference=$MISEQ_PATH/silva.v4.align);
	screen.seqs(fasta=current, count=current, start=1968, end=11550);
	filter.seqs(fasta=current, vertical=T, trump=.);
	unique.seqs(fasta=current, count=current);
	pre.cluster(fasta=current, count=current, diffs=2);
	chimera.uchime(fasta=current, count=current, dereplicate=T);
	remove.seqs(fasta=current, accnos=current);
	classify.seqs(fasta=current, count=current, reference=data/references/trainset9_032012.pds.fasta, taxonomy=data/references/trainset9_032012.pds.tax, cutoff=80);
	remove.lineage(fasta=current, count=current, taxonomy=current, taxon=Chloroplast-Mitochondria-unknown-Archaea-Eukaryota);"



# Garbage collection
rm $MISEQ_PATH/silva.v4.8mer
rm $MISEQ_PATH/silva.v4.align
rm $MISEQ_PATH/silva.v4.summary
rm $MISEQ_PATH/*.contigs.good.groups
rm $MISEQ_PATH/*.contigs.groups
rm $MISEQ_PATH/*.contigs.report
rm $MISEQ_PATH/*.scrap.contigs.fasta
rm $MISEQ_PATH/*.trim.contigs.bad.accnos
rm $MISEQ_PATH/*.trim.contigs.fasta
rm $MISEQ_PATH/*.trim.contigs.good.count_table
rm $MISEQ_PATH/*.trim.contigs.good.fasta
rm $MISEQ_PATH/*.trim.contigs.good.good.count_table
rm $MISEQ_PATH/*.trim.contigs.good.names
rm $MISEQ_PATH/*.trim.contigs.good.unique.align
rm $MISEQ_PATH/*.trim.contigs.good.unique.align.report
rm $MISEQ_PATH/*.trim.contigs.good.unique.bad.accnos
rm $MISEQ_PATH/*.trim.contigs.good.unique.fasta
rm $MISEQ_PATH/*.trim.contigs.good.unique.flip.accnos
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.align
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.count_table
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.fasta
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.fasta
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.count_table
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.fasta
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique*map
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.uchime.pick.count_table
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.uchime.chimeras
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.uchime.accnos
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.pick.pds.wang.tax.summary
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.pick.pds.wang.taxonomy
rm $MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.pick.pds.wang.pick.taxonomy
rm $MISEQ_PATH/*.filter

#keeping...
#	$MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta
#	$MISEQ_PATH/*.trim.contigs.good.unique.good.filter.unique.precluster.uchime.pick.pick.count_table
