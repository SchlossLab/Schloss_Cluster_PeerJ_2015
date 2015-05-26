#!bash

FASTA="$1"

mothur "#set.dir(input=data/he, output=data/he);
        unique.seqs(fasta=$FASTA);
        pairwise.seqs(fasta=current, processors=8, cutoff=0.20);
        cluster(column=current, name=current, method=average);
        cluster(column=current, name=current, method=furthest);
        cluster(column=current, name=current, method=nearest);"
