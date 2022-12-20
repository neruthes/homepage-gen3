#!/bin/bash

if [[ -z $VOLID ]]; then
    VOLID=002
fi

PDF_FILE_PATH="_dist/articles/Neruthes_articles_vol$VOLID.pdf"
TOC_PATH="./_dist/tex-tmp/Neruthes_articles_vol$VOLID.toc"

PDF_TOTAL_PAGES="$(qpdf --show-npages "$PDF_FILE_PATH")"
FINAL_PAGE="$((PDF_TOTAL_PAGES-1))"

function parseline() {
    ln=$1
    line1="$(head -n$ln $GREP_MATCH | tail -n1)"
    article_date="$(cut -d'{' -f4 <<< "$line1" | cut -c1-10)"
    article_title="$(cut -d'}' -f3 <<< "$line1" )"
    article_page_start="$(cut -d'}' -f4 <<< "$line1" | cut -c2-)"
    echo "article_date=$article_date"
    echo "article_title=$article_title"
    echo "article_page_start=$((article_page_start+1))"
    line2="$(head -n$((ln+1)) $GREP_MATCH | tail -n1)"
    # echo "ln=$ln  total_lines=$(wc -l $GREP_MATCH | cut -d' ' -f1)"
    if [[ $ln == $MATCHED_LINES ]]; then
        ### The current line is the last line
        # echo "[INFO] The current line is the last line. The end page must be $FINAL_PAGE."
        echo "article_page_end=$((FINAL_PAGE+1))"
        return 0
    fi
    ### Usually...
    article_page_end="$(cut -d'}' -f4 <<< "$line2" | cut -c2-)"
    echo "article_page_end=$article_page_end"
}

function makesubpdf() {
    inputdata="$1"
    postid="$(printf "%03d\n" $linecount)"
    article_page_start="$(grep article_page_start <<< "$inputdata" | cut -d= -f2-)"
    article_page_end="$(grep article_page_end <<< "$inputdata" | cut -d= -f2-)"
    RANGED_NAME="p${postid}" pdfrange "$PDF_FILE_PATH" "$article_page_start-$article_page_end" "$OUTPUTDIR"
}



OUTPUTDIR="_dist/articles-split/vol$VOLID"
mkdir -p $OUTPUTDIR


GREP_MATCH=".tmp/subpdf.match.txt"
grep '{chapter}' $TOC_PATH > $GREP_MATCH
MATCHED_LINES="$(wc -l $GREP_MATCH | cut -d' ' -f1)"

IFS=$'\n'
linecount=1
while [[ $linecount -le $MATCHED_LINES ]]; do
    PARSED_INFO="$(parseline $linecount)"
    makesubpdf "$PARSED_INFO"
    linecount=$((linecount+1))
done

# parseline 1
