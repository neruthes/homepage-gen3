#!/bin/bash

function rebuild_all_tex_files() {
    for TEX_FILE_PATH in $(find -path '*/*.tex' | grep -v TMPL | sort); do
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
        DIR="wwwdist/$RAWDIR"
        INDEXFILE="$DIR/index.html"
        sed "s:HTMLTITLE:Neruthes | ${DIR^^}:" .src/dirindex.head.html > $INDEXFILE
        for ITEM in $(ls $DIR | grep -v 'index.html' | sort); do
            echo "<a class='dirindexlistanchor' href='./$ITEM'>$ITEM</a>" >> $INDEXFILE
        done
        cat .src/dirindex.tail.html >> $INDEXFILE
    done
}






case $1 in
    1)
        rsync -av --delete wwwsrc/ wwwdist/
        ;;
    2)
        rebuild_all_tex_files
        ;;
    3)
        rsync -av _dist/ wwwdist/ --exclude tex-tmp
        ;;
    4)
        make_indexhtml_for_dirs
        ;;
    99)
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
        TARBALLURL='https://nas-public-zt.neruthes.xyz/homepage-gen3-f2fe33d6fd3620c108a3db17/pkgdist/wwwdist.tar'
        ;;
    *|full)
        bash build.sh 1
        bash build.sh 2
        bash build.sh 3
        bash build.sh 4
        ;;
esac
