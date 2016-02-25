FASTA=$1
FASTA=data/he/he_1.0_01.fasta
REF=data/references/97_otus.fasta

CLOSED_PATH=$(echo $FASTA | sed 's/fasta/vclosed/')
rm -rf $CLOSED_PATH/
mkdir $CLOSED_PATH
mkdir $CLOSED_PATH/vsearch

code/vsearch/vsearch --sizeout --derep_fulllength $FASTA --minseqlength 30 --threads 1 --uc $CLOSED_PATH/vsearch/abundance_sorted.uc --output $CLOSED_PATH/vsearch/abundance_sorted.fna --strand both --log $CLOSED_PATH/vsearch/abundance_sorted.log
code/vsearch/vsearch --maxaccepts 16 --id 0.97 --minseqlength 30 --threads 1 --wordlength 8 --uc $CLOSED_PATH/vsearch/ref_clustered.uc --maxrejects 64 --strand both --db $REF --log $CLOSED_PATH/vsearch/ref_clustered.log --usearch_global $CLOSED_PATH/vsearch/abundance_sorted.fna

	unique_file_name <- "data/he/he_1.0_01.vclosed/vsearch/abundance_sorted.uc"
	clustered_file_name <- "data/he/he_1.0_01.vclosed/vsearch/ref_clustered.uc"

R -e "source(code/cvsearch_to_list.R); cvsearch_to_list.R('$CLOSED_PATH/vsearch/abundance_sorted.uc', '$CLOSED_PATH/vsearch/ref_clustered.uc')"

rm -rf $CLOSED_PATH/
