#!/bin/bash

# $1: <...>/results/<exp>/<variance>/0(0-9)
bindir=$(dirname "$0")
odir=$1
var=$(basename $(dirname "$odir"))

if [ ! "$var" = "pdarc_auto" ]
then
	exit 0
fi

cd /sys/kernel/mm/damon/admin/kdamonds/0/
echo 1 > ./contexts/0/schemes/0/quotas/goals/nr_goals
echo 999 > ./contexts/0/schemes/0/quotas/goals/0/target_value
echo 999 > ./contexts/0/schemes/0/quotas/goals/0/current_value
echo 1000 > ./contexts/0/schemes/0/quotas/reset_interval_ms
echo commit > ./state

last_psi=""
while :;
do
	now_psi=$(cat /proc/pressure/memory | grep some | awk '{print $5}' | \
		awk -F= '{print $2}')
	if [ ! "$last_psi" = "" ]
	then
		# 1% (10ms per second) PSI is the goal
		echo 10000 > /sys/kernel/mm/damon/admin/kdamonds/0/contexts/0/schemes/0/quotas/goals/0/target_value
		echo $((now_psi - last_psi)) > /sys/kernel/mm/damon/admin/kdamonds/0/contexts/0/schemes/0/quotas/goals/0/current_value
		echo commit_schemes_quota_goals > /sys/kernel/mm/damon/admin/kdamonds/0/state
	fi
	last_psi=$now_psi
	sleep 1
done
