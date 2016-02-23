# This script implements the sumaclust algorithm. Because the output is weird
# we change it into a mothur list file. The input is a degapped and redundant
# fasta file and the output is a list file where sumaclust is used as the method
# tag. We'll assume that sumaclust is in code/sumaclust_v1.0.20. We will also
# assign sequences to OTUs based on 97% similarity (-t 0.97) and because we want
# to eventually generate a list file we want to output the mapping file with the
# -O flag

FASTA=$1
SUMACLUST_CLUST=$(echo $FASTA | sed 's/fasta/sumaclust.clust/')

code/sumaclust_v1.0.20/sumaclust -t 0.97 data/he/he_0.2_01.fasta -O $SUMACLUST_CLUST >/dev/null

R -e "source('code/sumaclust_to_list.R'); sumaclust_to_list('$SUMACLUST_CLUST')"
rm $SUMACLUST_CLUST
