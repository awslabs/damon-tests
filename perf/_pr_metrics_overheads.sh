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

printf "%23s  " $metric
echo "orig	rec (overhead)	thp (overhead)	ethp (overhead)"

for w in $workloads
do
	orig_d=results/$w/orig/stat/$stat
	orig_nr=$(cat $orig_d/$metric | awk '{print $2}')
	sums[orig]=`awk -v a="${sums[orig]}" -v b="$orig_nr" 'BEGIN {print a + b}'`
	printf "%23s  %.3f" $w $orig_nr
	for var in rec thp ethp
	do
		d=results/$w/$var/stat/$stat
		number=$(cat $d/$metric | awk '{print $2}')
		overhead=`awk -v a="$orig_nr" -v b="$number" \
			'BEGIN {print (b / a - 1) * 100}'`
		sums[$var]=`awk -v a="${sums[$var]}" -v b="$number" 'BEGIN {print a + b}'`

		printf "  %8.3f (%6.2f)" $number $overhead
		if [ "$var" = "ethp" ]
		then
			printf "\n"
		fi
	done
done

orig_sum=${sums[orig]}
printf "%23s  %.3f" "total" $orig_sum
for var in rec thp ethp
do
	sum=${sums[$var]}
	overhead=`awk -v a="$orig_sum" -v b="$sum" \
		'BEGIN {print (b / a - 1) * 100}'`
	printf "  %8.3f (%6.2f)" $sum $overhead
done
printf "\n"
