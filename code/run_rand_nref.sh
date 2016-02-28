REF=$1
FASTA=data/rand_ref/miseq.unique.fasta


# Preparing the randomized database
DB_FOLDER=$(echo $REF | sed 's/fasta/ninja_db/')
DB_NAME=$(echo $DB_FOLDER | sed 's/data\/rand_ref\///')

rm -rf $DB_FOLDER
mkdir -p $DB_FOLDER

cp data/references/97_otus.taxonomy $DB_FOLDER/$DB_NAME.taxonomy

code/NINJA-OPS/bin/ninja_prep_linux $REF $DB_FOLDER/out_preDB.fa $DB_FOLDER/$DB_NAME.db
bowtie2-build $DB_FOLDER/out_preDB.fa $DB_FOLDER/$DB_NAME


# The clustering...
NINJA_FOLDER=$(echo $REF | sed 's/fasta/ninja/')

rm -rf $NINJA_FOLDER
mkdir $NINJA_FOLDER

code/NINJA-OPS/bin/ninja_filter_linux $FASTA $NINJA_FOLDER/ninja D 1 LOG

bowtie2-align-s --no-head -x $DB_FOLDER/$DB_NAME -S $NINJA_FOLDER/alignments.txt --np 0 --mp 1,1 --rdg 0,1 --rfg 0,1 --score-min L,0,-0.03 --norc -f $NINJA_FOLDER/ninja_filt.fa -p 4 --very-sensitive

code/NINJA-OPS/bin/ninja_parse_filtered_linux $NINJA_FOLDER/ninja $NINJA_FOLDER/alignments.txt $DB_FOLDER/$DB_NAME.db $DB_FOLDER/$DB_NAME.taxonomy --legacy LOG

# something is weird about the indices that NINJA-OPS is returning in the log
# file. taxonomically they're way off and I can't get them to match with what is
# in the alignments file. going to have to go this alone...
R -e "source('code/fix_ninja_indexing.R');fix_ninja_indexing('$NINJA_FOLDER', '$DB_FOLDER')"

# Cleaning up
rm -rf $DB_FOLDER $NINJA_FOLDER
