# This script implements the OTUClust algorithm. Because the output is weird
# we change it into a mothur list file. The input is a degapped and redundant
# fasta file and the output is a list file where otuclust is used as the method
# tag. We'll assume that OTUClust is in the user's path. We will also assign
# sequences to OTUs based on 97% similarity (-s 0.97) and because we want to
# include all of the sequences we'll keep the singletons (-m 1)

FASTA=$1
OTUCLUST_CLUST=$(echo $FASTA | sed 's/fasta/otuclust.clust/')
OTUCLUST_REP=$(echo $FASTA | sed 's/fasta/otuclust.rep/')

otuclust -f fasta $FASTA --out-clust $OTUCLUST_CLUST --out-rep $OTUCLUST_REP -s 0.97 -m 1

R -e "source('code/otuclust_to_list.R'); otuclust_to_list('$OTUCLUST_CLUST')"
rm $OTUCLUST_CLUST $OTUCLUST_REP
