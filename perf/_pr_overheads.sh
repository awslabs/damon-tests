#!/bin/bash

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


if [ "$custom_vars" ]
then
	vars=$custom_vars
fi

stat=$1
metric=$2

declare -A sums

printf $metric'_'$stat
for var in $vars
do
	if [ "$var" = "orig" ]; then continue; fi
	printf "\t%s" $var
done
printf "\n"

nr_workloads=0
for w in $workloads
do
	nr_workloads=$((nr_workloads + 1))
	orig_d=$ODIR_ROOT/$w/orig/stat/$stat
	orig_nr=$(cat $orig_d/$metric | awk '{print $2}')
	sums[orig]=$(float_add "${sums[orig]}" "$orig_nr")
	for var in $vars
	do
		if [ "$var" = "orig" ]; then continue; fi
		d=$ODIR_ROOT/$w/$var/stat/$stat
		number=$(cat $d/$metric | awk '{print $2}')
		overhead=$(float_overhead "$number" "$orig_nr")
		sums[$var]=$(float_add "${sums[$var]}" "$number")

		if [ "$var" = "rec" ]
		then
			printf "%s\t%.3f" $w $overhead
		else
			printf "\t%.3f" $overhead
		fi
	done
	printf "\n"
done

if [ ! "$metric" = "kdamond_cpu_util" ]
then
	printf "total"
	orig_sum=${sums[orig]}
	for var in $vars
	do
		if [ "$var" = "orig" ]; then continue; fi
		sum=${sums[$var]}
		overhead=$(float_overhead "$sum" "$orig_sum")
		printf "\t%.3f" $overhead
	done
	printf "\n"
fi

printf "average"
orig_average=$(float_divide "${sums[orig]}" "$nr_workloads")
for var in $vars
do
	if [ "$var" = "orig" ]; then continue; fi
	average=$(float_divide "${sums[$var]}" nr="$nr_workloads")
	overhead=$(float_overhead "$average" "$orig_average")
	printf "\t%.3f" $overhead
done
printf "\n"
