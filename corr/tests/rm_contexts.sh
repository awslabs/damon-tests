#!/bin/bash

damon_dir="/sys/kernel/debug/damon"

echo ctx > "$damon_dir/mk_contexts"
if [ ! -d "$damon_dir/ctx" ]
then
	echo "mk_contexts doesn't work!"
	exit 1
fi

echo ctx > "$damon_dir/rm_contexts"
if [ -d "$damon_dir/ctx" ]
then
	echo "rm_contexts doesn't work!"
	exit 1
fi

exit 0
