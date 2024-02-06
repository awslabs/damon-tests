#!/bin/bash

if [ $# -lt 7 ]
then
	echo "Usage: $0 <remote damon-tests path> <linux commit> <remote name> <remote url> <username> <port> <remote host>..."
	exit 1
fi

bindir=$(dirname "$0")
remote_damon_tests_dir=$1
linux_commit=$2
linux_remote_name=$3
linux_remote_url=$4
username=$5
port=$6
remote_hosts=(${@:7})
remote_hosts="${remote_hosts[*]}"

lazybox="$bindir/../../lazybox"

"$lazybox/parallel_ssh_cmds/ssh_parallel.sh" \
	--port "$port" --user "$username" \
	"cd $remote_damon_tests_dir/perf && \
	nohup ./setup.sh $linux_commit $linux_remote_name $linux_remote_url \
	> remote_setup_log 2>&1 &" $remote_hosts
