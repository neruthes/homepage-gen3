#!/bin/bash

LISTFILE=.data/articles/vol002typ/.alist.txt
dates_list="$(cut -d- -f1-3 $LISTFILE  | sort -u)"
function make_typ() {
	local typfn="$1"
	local ctr="$2"
	local pdffn="_dist/articles-split/vol002/$(cut -d/ -f2 <<< "$date").$ctr.pdf"
	dirname "$pdffn" | xargs mkdir -p
	cmdname=command
	[[ $DRY == y ]] && cmdname=echo
	"$cmdname" typst c ".data/articles/vol002typ/$typfn" "$pdffn" --root . --input article_file_name="$typfn"
	realpath "$pdffn" | xargs du -h
}

for date in $dates_list; do
	counter_in_date=0
	while read -r typfn; do
		echo "date=$date"
		# echo "typfn=$typfn"
		( make_typ "$typfn" "$counter_in_date" ) &
		counter_in_date=$((counter_in_date + 1))
		# [[ "$counter_in_date" -gt 1 ]] && echo "counter_in_date=$counter_in_date"
	done < <(grep "^$date-" "$LISTFILE")
done

echo "Waiting to complete all tasks..."
wait
