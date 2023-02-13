#!/bin/bash

if [[ -z $VOLID ]]; then
    VOLID=002
fi
if [[ -z $SKIP_LEAD ]]; then
    SKIP_LEAD=1  # Skip first pages
fi
if [[ -z $SKIP_TAIL ]]; then
    SKIP_TAIL=1  # Truncate last pages
fi

PDF_FILE_PATH="_dist/articles/Neruthes_articles_vol$VOLID.pdf"
TOC_PATH=".tmp/Neruthes_articles_vol$VOLID.toc"

PDF_TOTAL_PAGES="$(qpdf --show-npages "$PDF_FILE_PATH")"
FINAL_PAGE="$((PDF_TOTAL_PAGES-1))"

function parseline() {
    ln=$1
    line1="$(head "-n$ln" "$GREP_MATCH" | tail -n1)"
    article_title="$(cut -d'}' -f2 <<< "$line1" | cut -c2-)"
    article_page_start="$(cut -d'}' -f3 <<< "$line1" | cut -c2-)"
    article_date="$(find ".data/articles/vol$VOLID" -name '*.TEX' | while read -r fn; do
        match_first_line="$(head -n1 "$fn" | grep "$article_title")"
        if [[ -n "$match_first_line" ]]; then
            printf '%s' "$(grep -Eo '20[0-9]{2}-[0-9]{2}-[0-9]{2}' <<< "$match_first_line")"
            break
        fi
    done)"
    ### Data output
    echo "article_date=$article_date"
    echo "article_title=$article_title"
    echo "article_page_start=$((article_page_start+SKIP_LEAD))"
    if [[ "$ln" == "$MATCHED_LINES" ]]; then
        ### The current line is the last line
        echo "article_page_end=$((FINAL_PAGE+SKIP_LEAD-SKIP_TAIL))"      ### Remove the trailing page
        return 0
    fi
    ### Usually...
    line2="$(head -n$((ln+1)) $GREP_MATCH | tail -n1)"
    article_page_end="$(cut -d'}' -f3 <<< "$line2" | cut -c2-)"
    echo "article_page_end=$article_page_end"
}

function makesubpdf() {
    PARSED_LINE_INFO="$1"
    article_page_start="$(grep article_page_start <<< "$PARSED_LINE_INFO" | cut -d= -f2-)"
    article_page_end="$(grep article_page_end <<< "$PARSED_LINE_INFO" | cut -d= -f2-)"
    article_date="$(grep article_date <<< "$PARSED_LINE_INFO" | cut -d= -f2)"
    if [[ "$article_date" == "$lastdate" ]]; then
        local_index="$((local_index+1))"
    else
        local_index=0
    fi
    ### Create ranged subset
    RANGED_NAME="$article_date.$local_index" pdfrange "$PDF_FILE_PATH" "$article_page_start-$article_page_end" "$OUTPUTDIR"

    ### Generate db map for comments
    # echo "$article_date.$local_index|Vol2 [$article_date] $article_title" >> wwwsrc/.var/gh-disc-comments/list-without-discnum.txt

    lastdate="$article_date"
    echo "local_index=$local_index"
    echo "lastdate=$lastdate"
}



OUTPUTDIR="_dist/articles-split/vol$VOLID"
find "$OUTPUTDIR" -delete
mkdir -p "$OUTPUTDIR"


GREP_MATCH=".tmp/splitarticles.match.txt"
grep '{chapter}' "$TOC_PATH" > "$GREP_MATCH"
MATCHED_LINES="$(wc -l "$GREP_MATCH" | cut -d' ' -f1)"




IFS=$'\n'
itr=1
export lastdate=0
export local_index=0
while [[ $itr -le $MATCHED_LINES ]]; do
    PARSED_LINE_INFO="$(parseline $itr)"
    makesubpdf_output="$(makesubpdf "$PARSED_LINE_INFO")"
    export lastdate="$(grep lastdate= <<< "$makesubpdf_output" | cut -d= -f2)"
    export local_index="$(grep local_index= <<< "$makesubpdf_output" | cut -d= -f2)"
    itr=$((itr+1))
done

mkdir -p wwwsrc/.var/articles-split
listfn="wwwsrc/.var/articles-split/list$VOLID.txt"
find "_dist/articles-split/vol$VOLID" -type f | sort > "$listfn"





### TODO: Generate RSS
