#!/bin/bash

if [ $# -lt 3 ]
then
	echo "Usage: $0 <results dir>... <accumulated results/reports dir>"
	exit 1
fi

if [ ! -f "$CFG" ]
then
	echo "CFG should be set but \"CFG\""
	exit 1
fi

bindir=$(dirname "$0")
# assume lazybox is sibling of damon-tests
lazybox_dir="$bindir/../../lazybox"

nr_results_to_aggregate=$(($# - 1))
results_to_aggregate=(${@:1:$nr_results_to_aggregate})
dst_dir="${@: -1}"

if [ -d "$dst_dir" ]
then
	echo "destination dir $dst_dir already exist"
	exit 1
fi

mkdir -p "$dst_dir"

aggregate_results="$lazybox_dir/repeat_runs/aggregate_results.sh"
if [ ! -x "$aggregate_results" ]
then
	echo "aggregate_results.sh not found at $aggregate_results"
	exit 1
fi

echo "Aggregate results in ${results_to_aggregate[@]}"
"$aggregate_results" "${results_to_aggregate[@]}" "$dst_dir/results"

echo "make visual report"
"$bindir/mk_visual_report.sh" "$dst_dir/results" "$dst_dir/visual_report"

tmp_cfg="$CFG"_for_"$dst_dir"
cp "$CFG" "$tmp_cfg"
echo "ODIR_ROOT=$dst_dir/results" >> "$tmp_cfg"
export CFG="$tmp_cfg"
"$bindir/post.sh"
"$bindir/mk_reports.sh"
mv report "$dst_dir/"

rm "$tmp_cfg"
