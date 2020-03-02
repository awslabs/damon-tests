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

echo $metric"_overhead	rec	thp	ethp"

for w in $workloads
do
	orig_d=results/$w/orig/stat/$stat
	orig_nr=$(cat $orig_d/$metric | awk '{print $2}')
	for var in rec thp ethp
	do
		d=results/$w/$var/stat/$stat
		number=$(cat $d/$metric | awk '{print $2}')
		overhead=`awk -v a="$orig_nr" -v b="$number" \
			'BEGIN {print (b / a - 1) * 100}'`

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
