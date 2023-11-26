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

orig_dst_dir=$dst_dir
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
tmp_dst_dir="$orig_dst_dir/$timestamp/"

if [ ! -f "$CFG" ]
then
	echo "CFG should be set properly but \"$CFG\""
	exit 1
fi

if [ -d "$tmp_dst_dir" ]
then
	echo "destination dir $tmp_dst_dir already exist"
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

mkdir -p $tmp_dst_dir
for host in "${hosts[@]}"
do
	rsync -arvz -e "ssh -p $port" --progress \
		"$username@$host:$remote_results_path/" "$tmp_dst_dir/results.$host"
done

echo "aggregate the results at $tmp_dst_dir/results"
"$aggregate_results" "$tmp_dst_dir"/* "$tmp_dst_dir/results"

echo "remove raw results that not aggregated"
for host in "${hosts[@]}"
do
	rm -fr "$tmp_dst_dir/results.$host"
done

kernel_version=$(cat "$tmp_dst_dir"/results/*/*/*/*/kernel_version | head -n 1)
final_dst_dir="$orig_dst_dir/$kernel_version/$timestamp"
if [ -d "$final_dst_dir" ]
then
	echo "$final_dst_dir exist.  Temporal results is at $tmp_dst_dir"
	exit 1
fi
mkdir -p "$final_dst_dir"
mv "$tmp_dst_dir"/* "$final_dst_dir"/

"$bindir/mk_visual_report.sh" "$final_dst_dir/results" "$final_dst_dir/visual_report"

tmp_cfg="$CFG"_for_"$(date +%Y-%m-%d-%H-%M-%S)"
cp "$CFG" "$tmp_cfg"
echo "ODIR_ROOT=$final_dst_dir/results" >> "$tmp_cfg"
export CFG="$tmp_cfg"
"$bindir/post.sh"
"$bindir/mk_reports.sh"
mv report "$final_dst_dir/"

rm "$tmp_cfg"
