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

printf $metric'_'$stat
for v in $vars
do
	printf " %s" $v
done
printf "\n"

for w in $workloads
do
	for var in $vars
	do
		d=results/$w/$var/stat/$stat

		if [ ! -f $d/$metric ]; then
			continue
		fi
		number=$(cat $d/$metric | awk '{print $2}')

		if [ "$var" = "orig" ]
		then
			printf "%s\t%.3f" $w $number
		else
			printf "\t%.3f" $number
		fi
	done
	printf "\n"
done
