#!bash

FASTA=$1
ROOT=$(echo $FASTA | sed 's/fasta/vagc/' | sed 's/.ng//')

code/vsearch/vsearch --sizeout --derep_fulllength $FASTA --minseqlength 30 --threads 1 --uc $ROOT.sorted.uc --output $ROOT.sorted.fna --strand both --log $ROOT.sorted.log 

code/vsearch/vsearch --maxaccepts 16 --usersort --id 0.97 --minseqlength 30 --wordlength 8 --uc $ROOT.clustered.uc --cluster_smallmem $ROOT.sorted.fna --maxrejects 64 --strand both --log $ROOT.clustered.log --sizeorder

R -e "source('code/uc_to_list.R'); uc_to_list('$ROOT.sorted.uc', '$ROOT.clustered.uc')"

rm $ROOT.sorted.uc $ROOT.sorted.fna $ROOT.sorted.log $ROOT.clustered.uc $ROOT.clustered.log


