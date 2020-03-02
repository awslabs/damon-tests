#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: $0 <stat> <metric>"
	echo "	e.g., '$0 avg runtime'"
	exit 1
fi

BINDIR=`dirname $0`
source $BINDIR/full_config.sh

stat=$1
metric=$2

declare -A sums

echo $metric"_overhead	rec	thp	ethp"

for w in $workloads
do
	orig_d=results/$w/orig/stat/$stat
	orig_nr=$(cat $orig_d/$metric | awk '{print $2}')
	sums[orig]=`awk -v a="${sums[orig]}" -v b="$orig_nr" \
		'BEGIN {print a + b}'`
	for var in rec thp ethp
	do
		d=results/$w/$var/stat/$stat
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
		if [ "$var" = "ethp" ]
		then
			printf "\n"
		fi
	done
done

printf "total"
orig_sum=${sums[orig]}
for var in rec thp ethp
do
	sum=${sums[$var]}
	overhead=`awk -v a="$orig_sum" -v b="$sum" \
		'BEGIN {print (b / a - 1) * 100}'`
	printf "\t%.3f" $overhead
done
printf "\n"
