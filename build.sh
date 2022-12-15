#!/bin/bash

function rebuild_all_tex_files() {
    for TEX_FILE_PATH in $(ls */*.tex | grep -v 'articles/' | sort); do
        PDF_FILE_PATH="_dist/${TEX_FILE_PATH:0:-4}.pdf"
        if [[ ! -e $PDF_FILE_PATH ]]; then
            echo "Artifact does not exist! $PDF_FILE_PATH"
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
    DIRSLIST="$(find wwwdist -type d)"
    for DIR in $DIRSLIST; do
        RAWDIR="${DIR:8}"
        echo "RAWDIR: $RAWDIR"
        echo "[INFO] Generating 'index.html' for directory '$RAWDIR'..."
        # mkdir -p $DIR
        INDEXFILE="$DIR/index.html"
        sed "s:HTMLTITLE:Neruthes | ${RAWDIR^^}:" .src/dirindex.head.html \
            | sed "s|RAWDIRNAME|$RAWDIR|"  > $INDEXFILE
        for ITEM in $(ls $DIR | grep -v 'index.html' | sort); do
            if [[ -d $DIR/$ITEM ]]; then
                ITEM_SUFFIX="/"
            else
                ITEM_SUFFIX=""
            fi
            echo "<a class='dirindexlistanchor' href='./$ITEM$ITEM_SUFFIX'>$ITEM$ITEM_SUFFIX</a>" >> $INDEXFILE
        done
        cat .src/dirindex.tail.html >> $INDEXFILE
    done
}






if [[ ! -z $2 ]]; then
    for i in $*; do
        bash build.sh $i
    done
    exit
fi

case $1 in
    1|latex_articles)
        bash .data/articles/build.sh
        ntex articles/*.tex --2
        ;;
    2|latex_other)
        bash build.sh _texassets
        rebuild_all_tex_files
        ;;
    3|wwwdist)
        rsync -a --delete wwwsrc/ wwwdist/                      # Initialize
        bash build.sh _texassets                                 # Import texassets
        rm -rf wwwdist/texassets/                               # Clear texassets in wwwdist
        rsync -a --delete .texassets/ wwwdist/texassets/        # Reload from latest texassets
        rsync -a _dist/ wwwdist/ --exclude tex-tmp              # Copy PDF into wwwdist
        make_indexhtml_for_dirs                                 # Generate 'index.html' for all subdirs
        rsync -av wwwsrc/ wwwdist/                              # Reload necessary 'index.html' files
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
        ### Build other archives
        zip -9vr pkgdist/wwwdist wwwdist
        rm /tmp/fulltarball.tar 2>/dev/null
        tar -cvf /tmp/fulltarball.tar \
            --exclude='.cloudbuildroot' \
            --exclude='.testground' \
            --exclude='pkgdist' \
            --exclude='.git' \
            .
        cat /tmp/fulltarball.tar > pkgdist/fulltarball.tar
        ;;
    5|oss)
        shareDirToNasPublic -a
        cfoss pkgdist/wwwdist.tar &&
        cfoss pkgdist/wwwdist.zip &&
        cfoss pkgdist/fulltarball.tar
        # OSSURL=https://oss-r2.neruthes.xyz/o/wwwdist.tar--00ef643fb4afb6610f3adbbb0ac4fc7c.tar
        # OSSURL=https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/o/wwwdist.tar--00ef643fb4afb6610f3adbbb0ac4fc7c.tar
        # OSSURL=https://oss-r2.neruthes.xyz/o/wwwdist.zip--b541ef4f9e09d35ed02d639dada83215.zip
        # OSSURL=https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/o/wwwdist.zip--b541ef4f9e09d35ed02d639dada83215.zip
        # OSSURL=https://oss-r2.neruthes.xyz/o/fulltarball.tar--06e9cd96e2fe53f96483bc814e8398c4.tar
        # OSSURL=https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/o/fulltarball.tar--06e9cd96e2fe53f96483bc814e8398c4.tar
        ;;
    _texassets)
        assetsdir=".texassets"
        ### Directory: video-cover
        tbcache $HOME/PIC/NeruthesVideoCovers
        rm -rf $assetsdir/video-cover
        # for imgrealpath in $HOME/PIC/NeruthesVideoCovers/*/.tbcache/*.jpg; do
        #     mkdir -p $assetsdir/video-cover/$(cut -d/ -f6 <<< $imgrealpath)
        #     cp  $imgrealpath  $assetsdir/video-cover/$(cut -d/ -f6,8 <<< $imgrealpath)
        # done
        for imgrealpath in $HOME/PIC/NeruthesVideoCovers/*/*.jpg; do
            mkdir -p $assetsdir/video-cover/$(cut -d/ -f6 <<< $imgrealpath)
            cp  $imgrealpath  $assetsdir/video-cover/$(cut -d/ -f6- <<< $imgrealpath)
        done
        ### End
        du -xhd1 $assetsdir
        ;;
    90|test)
        if [[ $USER == neruthes ]]; then
            bash cloudbuild.sh
        fi
        ;;
    99|deploy)
        pushgithubdistweb --now
        git add .
        git commit -m "Automatic deploy command: $(TZ=UTC date -Is | cut -c1-19 | sed 's/T/ /')"
        git push
        ;;
    full|'')
        echo "[INFO] Staring a full build-deloy workflow..."
        sleep 2
        bash build.sh latex_other _texassets wwwdist tarball oss
        if [[ "$?" != 0 ]]; then
            ### Uploading with cfoss is not successful
            echo "[ERROR] OSS upload failed. Cannot proceed."
            exit 1
        fi
        #---------------------------
        echo "[INFO] Wait 60s before initiating cloud-deploy, allowing Cloudflare R2 to purge the old tarball..."
        SLEPT_TIME=0
        while [[ $SLEPT_TIME -lt 60 ]]; do
            sleep 1; SLEPT_TIME=$((SLEPT_TIME+1)) ; printf "                \r   Progress:   $SLEPT_TIME / 60  ";
        done
        printf '\n'
        #---------------------------
        bash build.sh deploy
        ;;
    *)
        echo "[ERROR] No rule to build '$1'. Stopping."
        echo "Acceptable rules:"
            echo "latex_articles  latex_other  _texassets  wwwdist  tarball  oss  fulltarball  test  deploy"
        ;;
esac
