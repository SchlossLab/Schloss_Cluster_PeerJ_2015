# This script implements the sortmerna algorithm as implemented in qiime.
# Because the output is weird we change it into a mothur list file. The input
# is a degapped and redundant fasta file and the output is a list file where
# sortmerna is used as the method tag. We'll assume that QIIME is in the PATH.
# We will also assign sequences to OTUs based on 97% similarity (default). The
# peculiarity of the output file is that the reference is the first column and
# the matching sequences are in subsequent columns.

FASTA=$1
SORTMERNA=$(echo $FASTA | sed 's/fasta/sortmerna/')
rm -rf $SORTMERNA/

parallel_pick_otus_sortmerna.py -i $FASTA -o $SORTMERNA -r data/references/97_otus.fasta -T --jobs_to_start 1 --threads 10 --sortmerna_db data/references/97_otus.idx

R -e "source('code/sortmerna_to_list.R'); sortmerna_to_list('$SORTMERNA')"

rm -rf $SORTMERNA
