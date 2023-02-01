#!/bin/bash

find _dist/articles-split -name '*.pdf' | sort | while read -r pdfpath; do
    pdfid="$(basename "$pdfpath" | cut -d. -f1-2)"
    if [[ -z "$(find wwwsrc/.var -name "$pdfid.json")" ]] || [[ $LISTALL == y ]]; then
        raw_volid="$(cut -d/ -f3 <<< "$pdfpath")"
        volid="$(cut -c6 <<< "$raw_volid")"
        seq_in_vol=99999
        loop_counter=1
        for fn_itr in $(find "_dist/articles-split/$raw_volid" -name '*.pdf' | sort); do
            if [[ "$pdfid.pdf" == "$(basename "$fn_itr")" ]]; then
                seq_in_vol=$loop_counter
            fi
            loop_counter=$((loop_counter+1))
        done
        echo "--------------------------------------"
        echo -e "URL:       https://github.com/neruthes/homepage-gen3/discussions/new?category=blog-comments"
        echo -e "Title:     Vol$volid [${pdfid:0:10}] $(head -n$seq_in_vol ".tmp/Neruthes_articles_$raw_volid.toc" | tail -n1 | cut -d'}' -f3)\n"
        echo -e "Collection [Volume $volid]: https://neruthes.xyz/articles/Neruthes_articles_$raw_volid.pdf\n"
        echo -e "Atomic PDF: https://neruthes.xyz/articles-split/$raw_volid/$pdfid.pdf"
    fi
done
