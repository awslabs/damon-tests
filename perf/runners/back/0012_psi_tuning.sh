#!/bin/bash

# $1: <...>/results/<exp>/<variance>/0(0-9)
bindir=$(dirname "$0")
odir=$1
var=$(basename $(dirname "$odir"))

if [ ! "$var" = "pdarc_auto" ]
then
	exit 0
fi

sysfs_dir="/sys/kernel/mm/damon/admin/kdamonds/0/"
goals_dir="$sysfs_dir/contexts/0/schemes/0/quotas/goals/"
goal_dir="$sysfs_dir/contexts/0/schemes/0/quotas/goals/0"

last_psi=""
while :;
do
	now_psi=$(cat /proc/pressure/memory | grep some | awk '{print $5}' | \
		awk -F= '{print $2}')
	if [ ! "$last_psi" = "" ]
	then
		# 1% (10ms per second) PSI is the goal
		echo 1 > "$goals_dir/nr_goals"
		echo 10000 > "$goal_dir/target_value"
		echo $((now_psi - last_psi)) > "$goal_dir/current_value"
		echo commit_schemes_quota_goals > "$sysfs_dir/state"
	fi
	last_psi=$now_psi
	sleep 1
done
