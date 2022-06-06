#!/bin/bash

if [ $# -lt 5 ]
then
	echo "Usage: $0 <remote results path> <username> <port> <remote host>... <dst dir>"
	echo
	echo "Fetch remote results, aggregate, and make report in <dst dir>"
	exit 1
fi

bindir=$(dirname "$0")
# assume lazybox is sibling of damon-tests
lazybox_dir="$bindir/../../lazybox"

remote_results_path=$1
username=$2
port=$3
nr_hosts=$(($# - 4))
hosts=(${@:4:$nr_hosts})
dst_dir="${@: -1}"

if [ ! -f $CFG ]
then
	echo "CFG should be set properly but \"$CFG\""
	exit 1
fi

if [ -d "$dst_dir" ]
then
	echo "destination dir $dst_dir already exist"
	exit 1
fi

aggregate_results="$lazybox_dir/repeat_runs/aggregate_results.sh"
if [ ! -x "$aggregate_results" ]
then
	echo "aggregate_results.sh not found at $aggregate_results"
	exit 1
fi

if ! which gnuplot
then
	echo "seems gnuplot not installed?"
	exit 1
fi

echo "fetch remote results at $remote_results_path from"
for host in "${hosts[@]}"
do
	echo "	$username@$host of port $port"
done

mkdir $dst_dir
for host in "${hosts[@]}"
do
	rsync -arvz -e "ssh -p $port" --progress \
		"$username@$host:$remote_results_path/" "$dst_dir/results.$host"
done

echo "aggregate the results at $dst_dir/results"
"$aggregate_results" "$dst_dir"/* "$dst_dir/results"

echo "remove raw results that not aggregated"
for host in "${hosts[@]}"
do
	rm -fr "$dst_dir/results.$host"
done

"$bindir/mk_visual_report.sh" "$dst_dir/results" "$dst_dir/visual_report"

tmp_cfg="%CFG_for_$dst_dir"
cp "$CFG" "$tmp_cfg"
echo "ODIR_ROOT=$dst_dir/results" >> "$tmp_cfg"
export CFG="$tmp_cfg"
"$bindir/post.sh"
"$bindir/mk_reports.sh"
mv reports "$dst_dir/"

rm "$tmp_cfg"
