#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <output dir>"
	exit 1
fi

cpu_usage_file=$1/kdamond_cpu_usage
rm "$cpu_usage_file"
touch "$cpu_usage_file"

cpuacct_cgroup_mounted="false"
cpuacct_cgroup_root="/sys/fs/cgroup"

while read -r line
do
	options=$(echo "$line" | awk '{print $6}')
	if echo "$options" | grep -q "cpuacct"
	then
		cpuacct_cgroup_root=$(echo "$line" | awk '{print $3}')
		cpuacct_cgroup_dir="$cpuacct_cgroup_root/kdamond"
		echo "found cpuacct cgroup $cpuacct_cgroup_root"
		if [ -d "$cpuacct_cgroup_dir" ]
		then
			if [ ! "$(cat "$cpuacct_cgroup_dir/tasks")" = "" ]
			then
				echo "someone is using kdamond cgroup"
				exit 1
			fi
		else
			if ! mkdir "$cpuacct_cgroup_dir"
			then
				echo "cpuacct cgroup dir creation failed"
				exit 1
			fi
		fi
		cpuacct_cgroup_mounted="true"
		break
	fi
done < <(mount | grep -e "^cgroup on ")

if [ "$cpuacct_cgroup_mounted" = "false" ]
then
	cpuacct_cgroup_root="/sys/fs/cgroup"
	if ! mount -t cgroup -ocpuacct none /sys/fs/cgroup
	then
		echo "cpuacct cgroup mount failed"
		exit 1
	fi
	cpuacct_cgroup_dir="$cpuacct_cgroup_root/kdamond"
	if ! mkdir "$cpuacct_cgroup_dir"
	then
		echo "cpuacct cgroup dir creation failed"
		exit 1
	fi
	cpuacct_cgroup_mounted="true"
fi

start_usage=""
start_time=""
kdamond_pid="none"
kdamond_pid_file="/sys/kernel/debug/damon/kdamond_pid"
while :;
do
	sleep 1
	if [ "$kdamond_pid" = "none" ]
	then
		kdamond_pid=$(cat "$kdamond_pid_file")
		continue
	fi

	if [ "$start_time" = "" ]
	then
		echo "monitor kdamond ($kdamond_pid)"
		start_time=$SECONDS
		start_usage=$(cat "$cpuacct_cgroup_dir/cpuacct.usage")
		echo "$kdamond_pid" > "$cpuacct_cgroup_dir/tasks"
	fi

	now_usage=$(cat "$cpuacct_cgroup_dir/cpuacct.usage")
	cpu_usage=$((now_usage - start_usage))
	runtime=$((SECONDS - start_time))
	if [ "$runtime" = "0" ]
	then
		continue
	fi

	cpu_util=$(awk -v use_ns="$cpu_usage" -v total_sec="$runtime" \
		'BEGIN {print use_ns / 1000000000 / total_sec}')
	echo "$cpu_util $cpu_usage $runtime" >> "$cpu_usage_file"
done
