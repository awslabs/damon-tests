#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <pid>"
	exit 1
fi

pid=$1

memcg_root="/sys/fs/cgroup/memory"
if ! mount | grep "$memcg_root" | grep "type cgroup"
then
	echo "seems memcg is unmounted at $memcg_root"
	exit 1
fi

memcg_dir="$memcg_root/damon-tests-perf"
if [ ! -d "$memcg_dir" ]
then
	if ! mkdir "$memcg_dir"
	then
		echo "$memcg_dir couldn't be made"
		exit 1
	fi
fi

current_memcg_tasks=$(cat "$memcg_dir/tasks")
if [ "$current_memcg_tasks" = "$pid" ]
then
	exit 0
fi

for current_memcg_task in $current_memcg_tasks
do
	echo "$current_memcg_tasks" > "$memcg_root/tasks"
done

echo "$pid" > "$memcg_dir/tasks"
