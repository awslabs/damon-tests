#!/bin/bash

# Do feedback-based quota autotune for "prcl_auto*" variants.
#
# var name is XXX_auto[_<goal_bp>].  The <goal_bp> means the target value of
# last 10 secs memory some PSI, in bp (per 10K).  1% by default.

# $1: <...>/results/<exp>/<variance>/0(0-9)
bindir=$(dirname "$0")
odir=$1
var=$(basename $(dirname "$odir"))

if ! echo "$var" | grep "prcl_auto" --quiet
then
	exit 0
fi

# var names are XXX_auto_<goal_bp>
psi_goal_bp=$(echo "$var" | awk -F_ '{print $3}')
if [ "$psi_goal_bp" = "" ]
then
	psi_goal_bp=100
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
	echo "$psi_goal_bp" > "$goal_dir/target_value"
	echo "$now_psi_bp" > "$goal_dir/current_value"
	echo commit_schemes_quota_goals > "$sysfs_dir/state"
	sleep 1
done
