#!/bin/bash

VOL_LIST="002"

for VOL in $VOL_LIST; do
    LISTFN="articles/.list/list-$VOL.TEX"
    echo "Working on Volume $VOL"
    rm "$LISTFN" 2>/dev/null
    for TEXFILE in $(ls articles/.vol$VOL/*.TEX | sort); do
        echo '\input{'"$TEXFILE"'}' >> $LISTFN
    done
    cat $LISTFN
done
