#!/bin/bash

source .env
source .localenv
function rss_header() {
    cat .src/rsslib/header.txt
    echo "<lastBuildDate>$(date)</lastBuildDate>"
}
function rss_footer() {
    cat .src/rsslib/footer.txt
}
function rss_item() {
    item_title="$1"
    item_pubdate="$2"
    permalink="$3"
    article_id="$4"
    pdfurl="https://neruthes.xyz/articles-split/$(find_volume "$article_id")/$article_id.pdf"
    echo "<item>
    <title>$item_title</title>
    <guid isPermaLink=\"false\">$permalink</guid>
    <link>$permalink</link>
    <pubDate>$item_pubdate</pubDate>
    <description><![CDATA[
        PDF Link: <a href=\"$pdfurl\">$pdfurl</a><br/>
        Comments: <a href=\"$permalink\">$permalink</a>]]>
    </description>
</item>"
}
function find_volume() {
    article_id="$1"
    find _dist/articles-split -name '*.pdf' | grep "$article_id" | head -n1 | cut -d/ -f3
}


RSS_FN=wwwsrc/articles-rss.xml
rss_header > $RSS_FN


sort -r wwwsrc/.var/gh-disc-comments/full-list.txt | while IFS= read -r line; do
    article_id="$(cut -c1-12 <<< "$line")"
    title="$(cut -d' ' -f3- <<< "$line")"
    date="$(cut -c1-10 <<< "$line")"
    url="https://neruthes.xyz/articles-comments/?id=$article_id"
    rss_item "$title" "$date" "$url" "$article_id"
done >> $RSS_FN



rss_footer >> $RSS_FN
cat $RSS_FN
