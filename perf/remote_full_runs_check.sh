#!/bin/bash

if [ $# -lt 4 ]
then
	echo "Usage: $0 <remote damon-tests path> <username> <port> <remote host>..."
	exit 1
fi

bindir=$(dirname "$0")
remote_damon_tests_dir=$1
username=$2
port=$3
remote_hosts=(${@:4})

results=()
for remote_host in "${remote_hosts[@]}"
do
	final_log=$(ssh -p "$port" "$username@$remote_host" \
		tail -n 1 "$remote_damon_tests_dir/perf/remote_full_run_log")
	if echo "$final_log" | grep "tests ran from" | grep -q " to "
	then
		results+=("$remote_host seems finished: $final_log")
	else
		results+=("$remote_host seems not finished: $final_log")
	fi
done

for line in "${results[@]}"
do
	echo "$line"
done
