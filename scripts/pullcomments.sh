#!/bin/bash

source .env
source .localenv

mkdir -p .tmp1/gh-disc-index.d

GRAPHQL_TMPL="{ \
    \"query\": \
    \"query { \
        repository(owner: \\\"neruthes\\\", name: \\\"homepage-gen3\\\") { \
            discussion(number: discussion_num) { \
                id title url  \
                comments(first: 100) {edges{node{ id updatedAt author{ login url avatarUrl } bodyHTML }}} \
            } \
        } \
    }\"
}"


function process_line() {
    line="$1"
    if [[ "${line:0:1}" == '#' ]]; then
        return 0
    fi
    article_id="$(cut -d'|' -f1 <<< "$line")"
    discussion_num="$(cut -d'|' -f2 <<< "$line")"
    output_file="wwwsrc/.var/gh-disc-comments/${article_id:0:4}/$article_id.json"
    mkdir -p "$(dirname "$output_file")"
    if [[ "$VERB" == pull ]] && [[ "$line" == "$PREFIX"* ]]; then
        echo curl -X POST -H "$GITHUB_AUTH_HEADER" "https://api.github.com/graphql" -d "$(sed "s|discussion_num|$discussion_num|g" <<< "$GRAPHQL_TMPL")"
        curl -X POST -H "$GITHUB_AUTH_HEADER" "https://api.github.com/graphql" -d "$(sed "s|discussion_num|$discussion_num|g" <<< "$GRAPHQL_TMPL")" > "$output_file" || exit 1
        sleep 1
    fi
    echo "$line|$(jq -r .data.repository.discussion.title "$output_file")" > ".tmp1/gh-disc-index.d/$article_id.txt"
}

VERB="$1"


LISTFN="wwwsrc/.var/gh-disc-comments/full-list.txt"
printf '' > $LISTFN
cat wwwsrc/.var/gh-disc-comments/blog-discus-map-*.txt | while read -r line; do
    [[ "$line" == "20"* ]] && process_line "$line" || exit 1
done

cat .tmp1/gh-disc-index.d/*.txt > $LISTFN
