#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

float_add() {
	awk -v a="$1" -v b="$2" 'BEGIN {print a + b}'
}

float_overhead() {
	awk -v nr="$1" -v orig="$2" 'BEGIN {
		if (orig == 0)
			print nr
		else
			print (nr / orig - 1) * 100
	}'
}

float_divide() {
	awk -v a="$1" -v b="$2" 'BEGIN {print a / b}'
}

if [ $# -ne 2 ]
then
	echo "Usage: $0 <stat> <metric>"
	echo "	e.g., '$0 avg runtime'"
	exit 1
fi

ODIR_ROOT="results"

BINDIR=`dirname $0`
if [ -z "$CFG" ]
then
	CFG=$BINDIR/full_config.sh
fi
source $CFG

if [ ! -z "$custom_vars" ]
then
	vars=$custom_vars
fi

stat=$1
metric=$2

declare -A sums
declare -A overhead_sums

printf "%s" $metric
for v in $vars
do
	if [ "$v" = "orig" ]
	then
		printf "\t%s" $v
		continue
	fi
	printf "\t%s\t(overhead)" $v
done
printf "\n"

nr_workloads=0
for w in $workloads
do
	nr_workloads=$((nr_workloads + 1))
	orig_d=$ODIR_ROOT/$w/orig/stat/$stat
	orig_nr=$(cat $orig_d/$metric | awk '{print $2}')
	sums[orig]=$(float_add "${sums[orig]}" "$orig_nr")
	printf "%s\t%.3f" $w $orig_nr
	for var in $vars
	do
		if [ "$var" = "orig" ]
		then
			continue
		fi
		d=$ODIR_ROOT/$w/$var/stat/$stat
		number=$(cat $d/$metric | awk '{print $2}')
		overhead=$(float_overhead "$number" "$orig_nr")
		sums[$var]=$(float_add "${sums[$var]}" "$number")
		overhead_sums[$var]=$(float_add \
			"${overhead_sums[$var]}" "$overhead")

		printf "\t%.3f\t(%.2f)" $number $overhead
	done
	printf "\n"
done

orig_sum=${sums[orig]}
printf "%s\t%.3f" "total" $orig_sum
for var in $vars
do
	if [ "$var" = "orig" ]
	then
		continue
	fi

	sum=${sums[$var]}
	overhead=$(float_overhead "$sum" "$orig_sum")
	printf "\t%.3f\t(%.2f)" $sum $overhead
done
printf "\n"

orig_average=$(awk -v sum="${sums[orig]}" -v nr="$nr_workloads" \
	'BEGIN {print (sum / nr)}')
printf "%s\t%.3f" "average" $orig_average
for var in $vars
do
	if [ "$var" = "orig" ]
	then
		continue
	fi

	number_average=$(float_divide "${sums[$var]}" "$nr_workloads")
	overhead_average=$(float_divide \
		"${overhead_sums[$var]}" "$nr_workloads")

	printf "\t%.3f\t(%.2f)" $number_average $overhead_average
done
printf "\n"
