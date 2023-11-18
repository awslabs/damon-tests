#!/bin/bash

# Do feedback-based quota autotuning for "plrus_auto*" variants.
#
# var name is XXX_auto[_<goal_bp>].  The <goal_bp> means the target value of
# active pages size ratio, in bp (per 10K).  70% by default.

# $1: <...>/results/<exp>/<variance>/0(0-9)
bindir=$(dirname "$0")
odir=$1
var=$(basename $(dirname "$odir"))

if ! echo "$var" | grep "plrus_auto" --quiet
then
	exit 0
fi

# var names are plrus_auto_<goal_bp>
prio_goal_bp=$(echo "$var" | awk -F_ '{print $3}')
if [ "$prio_goal_bp" = "" ]
then
	prio_goal_bp=7000
fi
deprio_goal_bp=$((10000 - prio_goal_bp))

sysfs_dir="/sys/kernel/mm/damon/admin/kdamonds/0/"
# plrus equips two schemes, first one for prioritization, second one for
# deprioritization
prio_goals_dir="$sysfs_dir/contexts/0/schemes/0/quotas/goals/"
prio_goal_dir="$sysfs_dir/contexts/0/schemes/0/quotas/goals/0"
deprio_goals_dir="$sysfs_dir/contexts/0/schemes/1/quotas/goals/"
deprio_goal_dir="$sysfs_dir/contexts/0/schemes/1/quotas/goals/0"

while :;
do
	if [ ! -d "$goal_dir" ]
	then
		echo 1 > "$prio_goals_dir/nr_goals"
		echo 1 > "$deprio_goals_dir/nr_goals"
	fi

	active_mem=$(cat /proc/meminfo | grep "^Active: " | awk '{print $2}')
	inactive_mem=$(cat /proc/meminfo | grep "^Inactive: " | \
		awk '{print $2}')
	total_mem=$((active_mem + inactive_mem))
	active_bp=$((active_mem * 10000 / total_mem))
	inactive_bp=$((inactive_mem * 10000 / total_mem))

	echo "$prio_goal_bp" > "$prio_goal_dir/target_value"
	echo "$active_bp" > "$prio_goal_dir/current_value"
	echo "prio: $active_bp / $prio_goal_bp"

	echo "$deprio_goal_bp" > "$deprio_goal_dir/target_value"
	echo "$inactive_bp" > "$deprio_goal_dir/current_value"
	echo "deprio: $inactive_bp / $deprio_goal_bp"

	echo commit_schemes_quota_goals > "$sysfs_dir/state"

	sleep 1
done
