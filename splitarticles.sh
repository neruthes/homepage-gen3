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
    line1="$(head -n$ln $GREP_MATCH | tail -n1)"
    article_date="$(cut -d'{' -f4 <<< "$line1" | cut -c1-10)"
    article_title="$(cut -d'}' -f3 <<< "$line1" )"
    article_page_start="$(cut -d'}' -f4 <<< "$line1" | cut -c2-)"
    echo "article_date=$article_date"
    echo "article_title=$article_title"
    echo "article_page_start=$((article_page_start+SKIP_LEAD))"
    # echo "ln=$ln  total_lines=$(wc -l $GREP_MATCH | cut -d' ' -f1)"
    if [[ $ln == $MATCHED_LINES ]]; then
        ### The current line is the last line
        echo "article_page_end=$((FINAL_PAGE+SKIP_LEAD-SKIP_TAIL))"      ### Remove the trailing page
        return 0
    fi
    ### Usually...
    line2="$(head -n$((ln+1)) $GREP_MATCH | tail -n1)"
    article_page_end="$(cut -d'}' -f4 <<< "$line2" | cut -c2-)"
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
    RANGED_NAME="$article_date.$local_index" pdfrange "$PDF_FILE_PATH" "$article_page_start-$article_page_end" "$OUTPUTDIR"
    lastdate="$article_date"
    echo "local_index=$local_index"
    echo "lastdate=$lastdate"
}



OUTPUTDIR="_dist/articles-split/vol$VOLID"
mkdir -p $OUTPUTDIR
rm $OUTPUTDIR/*.pdf


GREP_MATCH=".tmp/splitarticles.match.txt"
grep '{chapter}' $TOC_PATH > $GREP_MATCH
MATCHED_LINES="$(wc -l $GREP_MATCH | cut -d' ' -f1)"




IFS=$'\n'
itr=1
export lastdate=0
export local_index=0
while [[ $itr -le $MATCHED_LINES ]]; do
    PARSED_LINE_INFO="$(parseline $itr)"
    makesubpdf_output="$(makesubpdf "$PARSED_LINE_INFO")"
    # echo "$makesubpdf_output"
    export lastdate="$(grep lastdate= <<< "$makesubpdf_output" | cut -d= -f2)"
    export local_index="$(grep local_index= <<< "$makesubpdf_output" | cut -d= -f2)"
    itr=$((itr+1))
done

mkdir -p wwwsrc/.var/articles-split
listfn="wwwsrc/.var/articles-split/list$VOLID.txt"
ls -1 _dist/articles-split/vol$VOLID | sort > $listfn





### TODO: Generate RSS
