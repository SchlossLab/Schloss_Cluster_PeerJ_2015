REF=$1

FASTA=data/rand_ref/miseq.unique.fasta


# For whatever reason, the reference idx files cannot be in the same linear
# path as the folder that the output goees to. here we set up a folder for the
# idx files that are next to the output folder. if we don't do this the computer
# just spins its wheels for a long time (forever?). Note that we generate new
# idx files for each randomization of the reference. Not sure whether this is
# necessary, but better safe than sorry and it makes sense that it be done.

IDX_FOLDER=$(echo $REF | sed 's/fasta/idx/')
IDX_FILE=$(echo $IDX_FOLDER/reference.idx)

mkdir -p $IDX_FOLDER
indexdb_rna --ref $REF,$IDX_FILE -v


# The clustering...

CLOSED_PATH=$(echo $REF | sed 's/fasta/sclosed/')
rm -rf $CLOSED_PATH/

parallel_pick_otus_sortmerna.py -i $FASTA -o $CLOSED_PATH -r $REF -T --jobs_to_start 1 --threads 10 --sortmerna_db $IDX_FILE


# Cleaning up

mv $CLOSED_PATH/miseq*_otus.txt $CLOSED_PATH.sc
rm -rf $CLOSED_PATH $IDX_FOLDER
