#!/bin/bash

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
	sums[orig]=`awk -v a="${sums[orig]}" -v b="$orig_nr" \
		'BEGIN {print a + b}'`
	for var in $vars
	do
		if [ "$var" = "orig" ]; then continue; fi
		d=$ODIR_ROOT/$w/$var/stat/$stat
		number=$(cat $d/$metric | awk '{print $2}')
		overhead=`awk -v a="$orig_nr" -v b="$number" \
			'BEGIN {print (b / a - 1) * 100}'`
		sums[$var]=`awk -v a="${sums[$var]}" -v b="$number" \
			'BEGIN {print a + b}'`

		if [ "$var" = "rec" ]
		then
			printf "%s\t%.3f" $w $overhead
		else
			printf "\t%.3f" $overhead
		fi
	done
	printf "\n"
done

printf "total"
orig_sum=${sums[orig]}
for var in $vars
do
	if [ "$var" = "orig" ]; then continue; fi
	sum=${sums[$var]}
	overhead=`awk -v a="$orig_sum" -v b="$sum" \
		'BEGIN {print (b / a - 1) * 100}'`
	printf "\t%.3f" $overhead
done
printf "\n"

printf "average"
orig_average=$(awk -v sum="${sums[orig]}" -v nr="$nr_workloads" \
	'BEGIN {print (sum / nr)}')
for var in $vars
do
	if [ "$var" = "orig" ]; then continue; fi
	average=$(awk -v sum="${sums[$var]}" -v nr="$nr_workloads" \
		'BEGIN {print (sum / nr)}')
	overhead=`awk -v a="$orig_average" -v b="$average" \
		'BEGIN {print (b / a - 1) * 100}'`
	printf "\t%.3f" $overhead
done
printf "\n"
