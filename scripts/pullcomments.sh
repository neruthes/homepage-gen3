#!/bin/bash

source .env
source .localenv

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
# GRAPHQL_TMPL="{ \"query\": \"query { \
#     viewer { login } } \
# \"}"
# DISCNUM


function process_line() {
    line="$1"
    if [[ "${line:0:1}" == '#' ]]; then
        return 0
    fi
    article_id="$(cut -d'|' -f1 <<< "$line")"
    discussion_num="$(cut -d'|' -f2 <<< "$line")"
    output_file="wwwsrc/.var/gh-disc-comments/${article_id:0:4}/$article_id.json"
    mkdir -p "$(dirname "$output_file")"
    if [[ "$VERB" == pull ]]; then
        curl -X POST -H "$GITHUB_AUTH_HEADER" "https://api.github.com/graphql" -d "$(sed "s|discussion_num|$discussion_num|g" <<< "$GRAPHQL_TMPL")" > $output_file
        sleep 1
    fi
    echo "$line|$(jq -r .data.repository.discussion.title $output_file)" >> wwwsrc/.var/gh-disc-comments/full-list.txt
}

VERB="$1"


printf '' > wwwsrc/.var/gh-disc-comments/full-list.txt
# cat wwwsrc/.var/gh-disc-comments/blog-discus-map-*.txt > wwwsrc/.var/gh-disc-comments/full-list.txt
IFS=$'\n'
for line in $(cat wwwsrc/.var/gh-disc-comments/blog-discus-map-*.txt); do
    process_line "$line"
done
