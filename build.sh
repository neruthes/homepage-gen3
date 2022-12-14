#!/bin/bash


## Preparations
touch .env .localenv
source .env
source .localenv


function rebuild_all_tex_files() {
    for TEX_FILE_PATH in $(ls */*.tex | grep -v 'articles/' | sort); do
        PDF_FILE_PATH="_dist/${TEX_FILE_PATH:0:-4}.pdf"
        if [[ ! -e $PDF_FILE_PATH ]]; then
            echo "Artifact does not exist! $PDF_FILE_PATH"
            ntex "$TEX_FILE_PATH" --2
        else
            if [[ $(date +%s -r $TEX_FILE_PATH) -gt $(date +%s -r $PDF_FILE_PATH) ]]; then
                echo "Must rebuild this file!"
                ntex "$TEX_FILE_PATH" --2
            fi
        fi
    done
}

function make_indexhtml_for_dirs() {
    DIRSLIST="$(find wwwdist -type d)"
    for DIR in $DIRSLIST; do
        RAWDIR="${DIR:8}"
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

function __sitemap_urlitem() {
    echo "
<url>
    <loc>https://neruthes.xyz/$1</loc>
    <lastmod>$2</lastmod>
    <changefreq>hourly</changefreq>
    <priority>$3</priority>
</url>" >> sitemap.xml
}
function generate_sitemap_xml() {
    cd wwwdist
    ### Start
    DATENOW="$(date -Is)"
    echo '<?xml version="1.0" encoding="utf-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">' > sitemap.xml
    ### Middle
    __sitemap_urlitem "" "$DATENOW" "1"
    for i in articles/ articles/*.pdf articles-split/ lists/; do
        __sitemap_urlitem "$i" "$(date -r $i -Is)" "0.8"
    done
    for fpath in articles-split/*/*.pdf; do
        __sitemap_urlitem "$fpath" "$(date -r $fpath -Is)" "0.6"
    done
    ### End
    echo '</urlset>"' >> sitemap.xml
}

function die() {
    echo "$1"
    exit 1
}




if [[ ! -z $2 ]]; then
    for i in $*; do
        bash build.sh $i || die "[ERROR] Some problem happaned."
    done
    exit $?
fi

case $1 in
    tag)
        tag_suffix="$(git tag | grep $(date +%Y%m) | wc -l)"
        tagname="v$(date +%Y%m).$tag_suffix"
        echo git tag $tagname
        echo git push origin $tagname
        ;;
    _dist/articles-split/vol*/p*.pdf)
        echo "[INFO] Converting '$1' to image..."
        OUTFN="$(cut -d/ -f3-4 --output-delimiter=- <<< "$1")"
        rm ".tmp/split-img/$OUTFN-*.png" 2>/dev/null
        pdftoppm  "$1"  ".tmp/split-img/$OUTFN"  -png  -r 300  -gray
        du -h "$(realpath ".tmp/split-img/$OUTFN-1.png")"
        ;;
    _rclone)
        rclone sync -P -L  pkgdist  dropbox-main:devdistpub/homepage-gen3/pkgdist
        ;;
    _texassets)
        assetsdir=".texassets"
        ### Directory: video-cover
        rsync -av --delete  --exclude '/*/.tbcache' --include '/*/*.jpg' --exclude '/*/*.*' \
            $HOME/PIC/NeruthesVideoCovers/ \
            $assetsdir/video-cover/
        ### End
        echo "Size of assetsdir:"
        du -xhd1 $assetsdir
        ;;
    0|prepare)
        bash .data/articles/build.sh                            # Rebuild articles list
        bash build.sh _texassets                                # Import texassets
        ;;
    1|latex_articles)
        bash .data/articles/build.sh
        ntex articles/*.tex --2
        ;;
    2|latex_other)
        rebuild_all_tex_files
        ;;
    3|wwwdist)
        bash splitarticles.sh                                            # Split blog articles
        for html in wwwsrc/*.html; do
            ### Last resort when I forget to update the CurrentYear pointer
            sed -i "s|2012-2023 Neruthes. All rights reserved.|2012-$(date +%Y) Neruthes. All rights reserved.|" "$html"
        done
        rsync -a --delete wwwsrc/ wwwdist/                          # Initialize
        rm -rf wwwdist/texassets/                                   # Clear texassets in wwwdist
        rsync -a --delete .texassets/ wwwdist/texassets/            # Reload from latest texassets
        rsync -a _dist/ wwwdist/ --exclude tex-tmp --exclude .tmp   # Copy PDF into wwwdist
        make_indexhtml_for_dirs                                     # Generate 'index.html' for all subdirs
        rsync -av wwwsrc/ wwwdist/                                  # Reload necessary 'index.html' files
        sed "s|BUILDDATETIME|$(TZ=UTC date +%Y-%m-%d)|" wwwsrc/index.html > wwwdist/index.html
        generate_sitemap_xml
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
            --exclude='.tmp' \
            --exclude='_dist/.tmp' \
            --exclude='.cloudbuildroot' \
            --exclude='.testground' \
            --exclude='pkgdist' \
            --exclude='.git' \
            .
        cat /tmp/fulltarball.tar > pkgdist/fulltarball.tar
        ;;
    5|upload)
        shareDirToNasPublic -a
        for fn in pkgdist/*; do
            cfoss "$fn" || die "[ERROR] Failed to upload"
        done
        # https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/keep/homepage-gen3/wwwdist.tar--00ef643fb4afb6610f3adbbb0ac4fc7c.tar
        # https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/keep/homepage-gen3/wwwdist.zip--b541ef4f9e09d35ed02d639dada83215.zip
        # https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/keep/homepage-gen3/fulltarball.tar--06e9cd96e2fe53f96483bc814e8398c4.tar
        ;;
    90|test)
        if [[ $USER == neruthes ]]; then
            bash cloudbuild.sh
        fi
        ;;
    99|deploy)
        TZ=UTC date -Is > .deploydatemark
        pushgithubdistweb
        git add .
        git commit -m "Automatic deploy command: $(TZ=UTC date -Is | cut -c1-19 | sed 's/T/ /')"
        git push
        ;;
    999|afterdeploy)
        bash build.sh _rclone
        ;;
    full|'')
        echo "[INFO] Staring a full build-deloy workflow..."
        bash build.sh  prepare latex_other _texassets wwwdist tarball upload || die "[ERROR] OSS upload failed. Cannot proceed."
        #---------------------------
        WAIT_TIME=15
        echo "[INFO] Wait ${WAIT_TIME}s before initiating cloud-deploy, allowing Cloudflare R2 to purge the old tarball..."
        SLEPT_TIME=0
        while [[ "$SLEPT_TIME" -lt "$WAIT_TIME" ]]; do
            sleep 1; SLEPT_TIME=$((SLEPT_TIME+1)) ; printf "                \r   Progress:   $SLEPT_TIME / $WAIT_TIME  ";
        done
        printf '\n'
        #---------------------------
        bash build.sh deploy
        echo "[INFO] And other matters..."
        echo "   $ bash build.sh afterdeploy"
        ;;
    *)
        echo "[ERROR] No rule to build '$1'. Stopping."
        echo "Acceptable rules:"
        echo "  prepare  latex_articles  latex_other  wwwdist  tarball  upload  fulltarball  test  deploy  afterdeploy"
        ;;
esac
