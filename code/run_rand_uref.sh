REF=$1
FASTA=data/rand_ref/miseq.fasta
CLOSED_PATH=$(echo $REF | sed 's/fasta/uclosed/')
rm -rf $CLOSED_PATH/

pick_closed_reference_otus.py -i $FASTA -r $REF -o $CLOSED_PATH -p code/closedref.params.txt
mv $CLOSED_PATH/usearch61_ref_picked_otus/ref_clustered.uc $CLOSED_PATH.uc

rm -rf $CLOSED_PATH/

