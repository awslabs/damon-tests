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
remote_hosts="${remote_hosts[*]}"

lazybox="$bindir/../../lazybox"

"$lazybox/parallel_ssh_cmds/ssh_parallel.sh" \
	--port "$port" --user "$username" \
	"cd $remote_damon_tests/perf && nohup ./full_run.sh > remote_full_run_log & nohup dmesg -w > remote_full_run_dmesg &" $remote_hosts
