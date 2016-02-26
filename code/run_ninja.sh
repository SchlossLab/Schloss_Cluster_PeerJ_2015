FASTA=$1
DB_STUB=code/NINJA-OPS/databases/greengenes97/greengenes97

NINJA_FOLDER=$(echo $FASTA | sed 's/fasta/ninja/')

rm -rf $NINJA_FOLDER
mkdir $NINJA_FOLDER
code/NINJA-OPS/bin/ninja_filter_linux $FASTA $NINJA_FOLDER/ninja D 1 LOG

bowtie2-align-s --no-head -x $DB_STUB -S $NINJA_FOLDER/alignments.txt --np 0 --mp 1,1 --rdg 0,1 --rfg 0,1 --score-min L,0,-0.03 --norc -f $NINJA_FOLDER/ninja_filt.fa -p 4 -k 1 --very-sensitive

code/NINJA-OPS/bin/ninja_parse_filtered_linux $NINJA_FOLDER/ninja $NINJA_FOLDER/alignments.txt $DB_STUB.db $DB_STUB.taxonomy --legacy LOG

R -e "source('code/ninja_to_list.R');ninja_to_list('$NINJA_FOLDER')"

rm -rf $NINJA_FOLDER
