#!/bin/bash

raw_dir=$1

# input is in format of: 'real    0m50.592s'
runtime=$(grep -e '^real' $1/commlog | sed 's/^real//' | \
	awk -F'[ms]' '{print $1 * 60 + $2}')
echo "runtime: $runtime" > $2/runtime

# $1 is <...>/<workload>/(orig|rec|thp|ethp)/[0-9][0-9]
orig_raw_commlog=$raw_dir/../../orig/`basename $raw_dir`/commlog
if [ -f $orig_raw_commlog ]
then
	orig_runtime=$(grep -e '^real' $orig_raw_commlog | sed 's/^real//' | \
		awk -F'[ms]' '{print $1 * 60 + $2}')
	overhead=`awk -v a="$runtime" -v b="$orig_runtime" \
		'BEGIN{print (a / b - 1) * 100}'`
	echo "overhead: $overhead" > $2/overhead_runtime
fi
