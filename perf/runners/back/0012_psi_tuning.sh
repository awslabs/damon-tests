#!/bin/bash

# Do feedback-based quota autotune for "*-auto" variants, aiming 1% last 10
# secs memory some PSI

# $1: <...>/results/<exp>/<variance>/0(0-9)
bindir=$(dirname "$0")
odir=$1
var=$(basename $(dirname "$odir"))

if ! echo "$var" | grep "_auto$" --quiet
then
	exit 0
fi

sysfs_dir="/sys/kernel/mm/damon/admin/kdamonds/0/"
goals_dir="$sysfs_dir/contexts/0/schemes/0/quotas/goals/"
goal_dir="$sysfs_dir/contexts/0/schemes/0/quotas/goals/0"

while :;
do
	if [ ! -d "$goal_dir" ]
	then
		echo 1 > "$goals_dir/nr_goals"
	fi

	now_psi_bp=$(cat /proc/pressure/memory | grep some | awk '{print $2}' | \
		awk -F= '{print $2 * 100}')
	echo 100 > "$goal_dir/target_value"
	echo "$now_psi_bp" > "$goal_dir/current_value"
	echo commit_schemes_quota_goals > "$sysfs_dir/state"
	sleep 1
done
