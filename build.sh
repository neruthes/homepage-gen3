#!/bin/bash

function rebuild_all_tex_files() {
    for TEX_FILE_PATH in $(find -path '*/*.tex' | grep -v '/articles/' | sort); do
        PDF_FILE_PATH="_dist/${TEX_FILE_PATH:2:-4}.pdf"
        if [[ ! -e $PDF_FILE_PATH ]]; then
            echo "Artifact does not exist!"
            ntex "$TEX_FILE_PATH" --2
        else
            if [[ $(date +%s -r $TEX_FILE_PATH) -gt $(date +%s -r $PDF_FILE_PATH) ]]; then
                echo "Must rebuild this file!"
                ntex "$TEX_FILE_PATH"
            fi
        fi
    done
}

function make_indexhtml_for_dirs() {
    INDEXABLE_DIRS_LIST="articles"
    for RAWDIR in $INDEXABLE_DIRS_LIST; do
        echo "[INFO] Generating 'index.html' for directory '$RAWDIR'..."
        DIR="wwwdist/$RAWDIR"
        INDEXFILE="$DIR/index.html"
        sed "s:HTMLTITLE:Neruthes | ${RAWDIR^^}:" .src/dirindex.head.html | sed "s|DIRNAME|$RAWDIR|" > $INDEXFILE
        for ITEM in $(ls $DIR | grep -v 'index.html' | sort); do
            echo "<a class='dirindexlistanchor' href='./$ITEM'>$ITEM</a>" >> $INDEXFILE
        done
        cat .src/dirindex.tail.html >> $INDEXFILE
    done
}






if [[ ! -z $2 ]]; then
    for i in $*; do
        bash $0 $i
    done
    exit
fi

case $1 in
    1|latex_articles)
        bash articles/build.sh
        ntex articles/*.tex --2
        ;;
    2|latex_other)
        rebuild_all_tex_files
        ;;
    3|wwwdist)
        rsync -a --delete wwwsrc/ wwwdist/
        rsync -a _dist/ wwwdist/ --exclude tex-tmp
        make_indexhtml_for_dirs
        ;;
    4|tarball)
        ### Build tarball
        # Clear
        find .testground -delete
        mkdir -p .testground
        rm pkgdist/wwwdist.tar 2>/dev/null
        # Build
        cd wwwdist
        tar -cvf ../pkgdist/wwwdist.tar ./
        cd ..
        # Test
        cd .testground
        tar -pxvf ../pkgdist/wwwdist.tar
        cd ..
        # Upload tarball
        shareDirToNasPublic -a
        if [[ $USER == neruthes ]]; then
            bash cloudbuild.sh
        fi
        ;;
    *|full)
        # bash build.sh latex_articles
        bash build.sh latex_other
        bash build.sh wwwdist
        bash build.sh tarball
        ;;
esac