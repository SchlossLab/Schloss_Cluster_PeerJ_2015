# This script implements the closed-reference algorithm from He et al. 2015 as 
# described in supplementary file 1. Because the output from QIIME is a 
# biom-formatted file, we change it into a shared file (sequences by OTUs) and
# then into a mothur list file. The input is a fasta file and the output is a
# list file where closed is used as the method tag

FASTA=$1
CLOSED_PATH=$(echo $FASTA | sed 's/fasta/closed/')

rm -rf $CLOSED_PATH/
pick_closed_reference_otus.py -i $FASTA -o $CLOSED_PATH -p code/closedref.params.txt
mothur "#set.dir(output=$CLOSED_PATH); make.shared(biom=$CLOSED_PATH/otu_table.biom)"
R -e "source('code/shared_to_list.R'); shared_to_list('$CLOSED_PATH/otu_table.shared')"
rm -rf $CLOSED_PATH/
