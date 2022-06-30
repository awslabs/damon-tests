#!/bin/bash
#
# Too-simplified TMO
# (https://www.pdl.cmu.edu/ftp/NVM/tmo_asplos22.pdf)

if [ $# -ne 3 ]
then
	# The paper uses below parameters
	# reclaim ratio: 5 bp (0.0005)
	# psi threshold: 10 bp (0.001)
	# interval: 6000 ms (6 seconds)
	#
	# For tests, radical values, say, 10%, 1% and 1000ms, might make sense
	echo "Usage: $0 <reclaim ratio (bp)> <psi threshold (bp)> <interval (ms)>"
	exit 1
fi

reclaim_ratio_bp=$1
psi_threshold_bp=$2
interval_ms=$3

cgroup_dir="/sys/fs/cgroup/unified"
memory_reclaim_file="$cgroup_dir/memory.reclaim"
memory_pressure_file="$cgroup_dir/memory.pressure"

before_psi_some_us=$(awk 'NR==1{print $5}' "$memory_pressure_file" | \
	awk -F= '{print $2}')
before_timestamp_us=$(date +%s%6N)

while :
do
	sleep "$(($interval_ms / 1000))"

	# get current PSI
	current_psi_some=$(awk 'NR==1{print $5}' "$memory_pressure_file" | \
		awk -F= '{print $2}')
	now_psi_some_us=$((current_psi_some - before_psi_some_us))
	now_timestamp_us=$(date +%s%6N)
	timedelta_us=$((now_timestamp_us - before_timestamp_us))
	psi_bp=$((now_psi_some_us * 10000 / timedelta_us))

	# get current used mem
	mem_total_kb=$(grep -m 1 MemTotal /proc/meminfo | awk '{print $2}')
	mem_free_kb=$(grep -m 1 MemFree /proc/meminfo | awk '{print $2}')
	current_mem_kb=$((mem_total_kb - mem_free_kb))

	# get amount of memory to reclaim
	max_reclaim_kb=$((current_mem_kb * reclaim_ratio_bp / 10000))
	if [ $psi_bp -ge $psi_threshold_bp ]
	then
		kb_to_reclaim="0K"
	else
		psi_reclaim_rate_bp=$((10000 - psi_bp * 10000 / psi_threshold_bp))
		kb_to_reclaim="$((max_reclaim_kb * psi_reclaim_rate_bp / 10000))K"
		echo "$kb_to_reclaim" > "$memory_reclaim_file"
	fi

	# for debugging
	echo "max reclaim: $max_reclaim_kb"
	echo "psi: $psi_bp"
	echo "psi thres: $psi_threshold_bp"
	echo "final reclaim: $kb_to_reclaim"

	before_psi_some_us=$now_psi_some_us
	before_timestamp_us=$now_timestamp_us
done
