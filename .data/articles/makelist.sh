#!/bin/bash

# bash .data/articles/makelist.sh

DRAFTDIR=".tmp1/draftarticles"
mkdir -p "$DRAFTDIR"

VOL_LIST="002"

for VOL in $VOL_LIST; do
    LISTFN=".data/articles/list/list-$VOL.TEX"
    echo "Working on Volume $VOL"
    ### Reset list
    rm "$LISTFN" "$LISTFN.draft" 2>/dev/null
    ### Build list for live document
    find .data/articles/vol$VOL -name '*.TEX' | sort | while read -r TEXFILE; do
        echo '\input{'"$TEXFILE"'}'
    done >> $LISTFN
    ### Build list for draft document
    find .data/articles/vol$VOL -iname '*.TEX' | sort | while read -r TEXFILE; do
        echo '\input{'"$TEXFILE"'}'
    done >> $LISTFN.draft
    ### Let the draft follow the live
    sed "s|list-$VOL.TEX|list-$VOL.TEX.draft|" articles/Neruthes_articles_vol$VOL.tex > $DRAFTDIR/Neruthes_articles_vol$VOL-draft.tex
done
