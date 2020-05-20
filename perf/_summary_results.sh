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

if [ ! -z "$custom_vars" ]
then
	vars=$custom_vars
fi

stat=$1
metric=$2

declare -A sums

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

for w in $workloads
do
	orig_d=$ODIR_ROOT/$w/orig/stat/$stat
	orig_nr=$(cat $orig_d/$metric | awk '{print $2}')
	sums[orig]=`awk -v a="${sums[orig]}" -v b="$orig_nr" \
		'BEGIN {print a + b}'`
	printf "%s\t%.3f" $w $orig_nr
	for var in $vars
	do
		if [ "$var" = "orig" ]
		then
			continue
		fi
		d=$ODIR_ROOT/$w/$var/stat/$stat
		number=$(cat $d/$metric | awk '{print $2}')
		overhead=`awk -v a="$orig_nr" -v b="$number" \
			'BEGIN {print (b / a - 1) * 100}'`
		sums[$var]=`awk -v a="${sums[$var]}" -v b="$number" \
			'BEGIN {print a + b}'`

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
	overhead=`awk -v a="$orig_sum" -v b="$sum" \
		'BEGIN {print (b / a - 1) * 100}'`
	printf "\t%.3f\t(%.2f)" $sum $overhead
done
printf "\n"
