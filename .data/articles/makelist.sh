#!/bin/bash

DRAFTDIR=".tmp/draftarticles"
mkdir -p "$DRAFTDIR"

VOL_LIST="002"

for VOL in $VOL_LIST; do
    LISTFN=".data/articles/list/list-$VOL.TEX"
    echo "Working on Volume $VOL"
    ### Reset list
    rm "$LISTFN" "$LISTFN.draft" 2>/dev/null
    ### Build list for live document
    for TEXFILE in $(ls .data/articles/vol$VOL/*.TEX | sort); do
        echo '\input{'"$TEXFILE"'}' >> $LISTFN
    done
    ### Build list for draft document
    for TEXFILE in $(ls .data/articles/vol$VOL/* | sort); do
        echo '\input{'"$TEXFILE"'}' >> $LISTFN.draft
    done
    ### Let the draft follow the live
    sed "s|list-$VOL.TEX|list-$VOL.TEX.draft|" articles/Neruthes_articles_vol$VOL.tex > $DRAFTDIR/Neruthes_articles_vol$VOL-draft.tex
done
