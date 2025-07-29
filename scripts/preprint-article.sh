#!/bin/bash


tex_path="$1" # .data/articles/vol002/2025/2025-07-30-indep.TEX
basename="$(basename "$tex_path")"

dir_path=.tmp/preprint
mkdir -p "$dir_path"

tmp_path="$dir_path/$basename"


(
    cat scripts/deps/preprint-article.H.tex
    printf '\\begin{document}\n'
    cat "$tex_path"
    printf '\\end{document}\n'
) > "$tmp_path"


# cd "$dir_path" || exit 1
xelatex -output-directory="$dir_path" "$tmp_path"

# cd ../..|| exit 1

ls "$dir_path"
echo "Remember to   rm -r $dir_path "

pdf_path="$(sed -E 's|[texTEX]+$||' <<< "$tmp_path")pdf"

realpath "$pdf_path" | xargs du -h
