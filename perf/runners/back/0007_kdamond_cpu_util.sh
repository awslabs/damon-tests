#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

if [ "$EUID" -ne 0 ]
then
	echo "run as root"
	exit 1
fi

if [ $# -ne 1 ]
then
	echo "Usage: $0 <output dir>"
	exit 1
fi

odir=$1
var=$(basename $(dirname "$odir"))

cpu_usage_file=$1/kdamond_cpu_usage
rm -f "$cpu_usage_file"
touch "$cpu_usage_file"

if [ "$var" = "orig" ] || [ "$var" = "thp" ] || [ "$var" = "ttmo" ]
then
	exit 0
fi

kdamond_pid="none"
kdamond_pid_file="/sys/kernel/debug/damon/kdamond_pid"
if [ -d "/sys/kernel/mm/damon/admin" ]
then
	kdamond_pid_file="/sys/kernel/mm/damon/admin/kdamonds/0/pid"
fi

# When kdamond is not running debugfs kdamond_pid file returns "none" while
# sysfs kdamond/pid file returns "-1"
while [ "$kdamond_pid" = "none" ] || [ "$kdamond_pid" = "-1" ]
do
	sleep 1
	# the sysfs file might not yet created
	if [ ! -f "$kdamond_pid_file" ]
	then
		echo "wait for ($kdamond_pid_file) creation"
		continue
	fi
	echo "wait for kdamond run"
	kdamond_pid=$(cat "$kdamond_pid_file")
done

echo "monitor kdamond ($kdamond_pid)"
kdamond_stat_file="/proc/$kdamond_pid/stat"
start_total_jiffies=$(cat /proc/timer_list | grep "^jiffies: " --max-count=1 | \
	awk '{print $2}')
# 15-th column is the kernel mode jiffies
start_kdamond_jiffies=$(cat "$kdamond_stat_file" | awk '{print $15}')

while :;
do
	sleep 1

	now_total_jiffies=$(cat /proc/timer_list | \
		grep "^jiffies: " --max-count=1 | awk '{print $2}')
	now_kdamond_jiffies=$(cat "$kdamond_stat_file" | awk '{print $15}')

	total_jiffies=$((now_total_jiffies - start_total_jiffies))
	kdamond_jiffies=$((now_kdamond_jiffies - start_kdamond_jiffies))
	kdamond_util=$(echo "$kdamond_jiffies $total_jiffies" | \
		awk '{print $1 / $2}')

	echo "$kdamond_util $kdamond_jiffies $total_jiffies" >> \
		"$cpu_usage_file"
done
