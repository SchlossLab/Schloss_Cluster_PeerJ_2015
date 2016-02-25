FASTA=$1
REF=data/references/97_otus.fasta

CLOSED_PATH=$(echo $FASTA | sed 's/fasta/vclosed/')
rm -rf $CLOSED_PATH/
mkdir $CLOSED_PATH
mkdir $CLOSED_PATH/vsearch

code/vsearch/vsearch --sizeout --derep_fulllength $FASTA --minseqlength 30 --threads 1 --uc $CLOSED_PATH/vsearch/abundance_sorted.uc --output $CLOSED_PATH/vsearch/abundance_sorted.fna --strand both --log $CLOSED_PATH/vsearch/abundance_sorted.log
code/vsearch/vsearch --maxaccepts 16 --id 0.97 --minseqlength 30 --threads 1 --wordlength 8 --uc $CLOSED_PATH/vsearch/ref_clustered.uc --maxrejects 64 --strand both --db $REF --log $CLOSED_PATH/vsearch/ref_clustered.log --usearch_global $CLOSED_PATH/vsearch/abundance_sorted.fna

R -e "source('code/cvsearch_to_list.R'); cvsearch_to_list('$CLOSED_PATH/vsearch/abundance_sorted.uc', '$CLOSED_PATH/vsearch/ref_clustered.uc')"

rm -rf $CLOSED_PATH/
