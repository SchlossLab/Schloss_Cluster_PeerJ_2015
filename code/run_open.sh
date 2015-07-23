# This script implements the open-reference algorithm from He et al. 2015 as 
# described in supplementary file 1. Because the output from QIIME is a 
# biom-formatted file, we change it into a mothur list file. The input is a
# fasta file and the output is a list file where open is used as the method tag

FASTA=$1
OPEN_PATH=$(echo $FASTA | sed 's/fasta/open/')

rm -rf $OPEN_PATH/
pick_open_reference_otus.py -i $FASTA -o $OPEN_PATH -m usearch61 -s 1 -p code/openref.params.txt --min_otu_size 1 --prefilter_percent_id 0.0
R -e "source('code/biom_to_list.R'); biom_to_list('$OPEN_PATH/otu_table_mc1_w_tax_no_pynast_failures.biom')"
rm -rf $OPEN_PATH/

