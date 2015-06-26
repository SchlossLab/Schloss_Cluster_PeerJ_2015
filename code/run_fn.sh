#!bash

DIST="$1"
NAMES="$2"

mothur "#cluster(column=$DIST, name=$NAMES, method=furthest);"

S_R_ABUND=$(echo $FASTA | sed 's/fasta/*abund/')

