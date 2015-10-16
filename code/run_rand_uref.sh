REF=$1
FASTA=data/rand_ref/miseq.fasta
CLOSED_PATH=$(echo $REF | sed 's/fasta/uclosed/')
rm -rf $CLOSED_PATH/
mkdir $CLOSED_PATH
mkdir $CLOSED_PATH/usearch

usearch61 --sizeout --derep_fulllength $FASTA --minseqlength 30 --threads 1 --uc $CLOSED_PATH/usearch/abundance_sorted.uc --output $CLOSED_PATH/usearch/abundance_sorted.fna --strand both --log $CLOSED_PATH/usearch/abundance_sorted.log 
usearch61 --maxaccepts 16 --id 0.97 --minseqlength 30 --threads 1 --wordlength 8 --uc $CLOSED_PATH/usearch/ref_clustered.uc --maxrejects 64 --strand both --db $REF --log $CLOSED_PATH/usearch/ref_clustered.log --usearch_global $CLOSED_PATH/usearch/abundance_sorted.fna

mv $CLOSED_PATH/usearch/ref_clustered.uc $CLOSED_PATH.uc
rm -rf $CLOSED_PATH/

