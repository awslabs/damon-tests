#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

LBX="$(dirname "$0")/../../../lazybox"
outfile="nr_used_pages"
in_dir=$1
out_dir=$2

"$LBX/scripts/report/memfree_to_used.py" "$in_dir/nr_free_pages" \
	> "$out_dir/$outfile"

sum=0
nr=0
for footprint in $(awk '{print $2}' "$out_dir/$outfile")
do
	sum=$((sum + footprint))
	nr=$((nr + 1))
done
echo "$outfile.avg: " $((sum / nr)) > "$out_dir/$outfile.avg"
