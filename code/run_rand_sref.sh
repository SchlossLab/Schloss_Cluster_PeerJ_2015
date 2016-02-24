REF=$1
#REF=data/rand_ref/rand_ref_1.0_03.fasta

FASTA=data/rand_ref/miseq.fasta
CLOSED_PATH=$(echo $REF | sed 's/fasta/sclosed/')

IDX_FILE=$(echo $REF | sed 's/fasta/idx/')

rm -rf $CLOSED_PATH/

indexdb_rna --ref $REF,$IDX_FILE -v

parallel_pick_otus_sortmerna.py -i $FASTA -o $CLOSED_PATH -r $REF -T --jobs_to_start 1 --threads 10 --sortmerna_db $IDX_FILE

mv $CLOSED_PATH/miseq_otus.txt $CLOSED_PATH.sc
rm -rf $CLOSED_PATH
rm $IDX_FILE*
