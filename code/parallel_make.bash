MAIN_TARGET=$1
LINES=$2

> $MAIN_TARGET.temp
TARGETS=$(make print-$MAIN_TARGET | sed 's/.*=//g')
for T in $TARGETS
do
    echo make $T >> $MAIN_TARGET.temp
done

split -l $LINES $MAIN_TARGET.temp

for X in x??
do
    cat head.batch $X tail.batch > $X.qsub
    qsub $X.qsub
#    rm $X.qsub $X
done

rm $MAIN_TARGET.temp

