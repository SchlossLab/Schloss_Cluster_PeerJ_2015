# This script implements the AGC algorithm from He et al. 2015 as described
# in supplementary file 1. Because the output from QIIME is a biom-formatted
# file, we change it into a shared file (sequences by OTUs) and then into a
# mothur list file. The input is a fasta file and the output is a list file
# where agc is used as the method tag

FASTA=$1
AGC_PATH=$(echo $FASTA | sed 's/fasta/agc/')

rm -rf $AGC_PATH/
pick_de_novo_otus.py -i $FASTA -o $AGC_PATH -p code/agc.params.txt
mothur "#set.dir(output=$AGC_PATH); make.shared(biom=$AGC_PATH/otu_table.biom)"
R -e "source('code/shared_to_list.R'); shared_to_list('$AGC_PATH/otu_table.shared')"
rm -rf $AGC_PATH/

