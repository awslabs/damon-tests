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

echo $metric "orig rec thp ethp"

for w in $workloads
do
	for var in orig rec thp ethp
	do
		d=results/$w/$var/stat/$stat

		number=$(cat $d/$metric | awk '{print $2}')

		if [ "$var" = "orig" ]
		then
			printf "%s\t%s" $w $number
		else
			printf "\t%s" $number
		fi
		if [ "$var" = "ethp" ]
		then
			printf "\n"
		fi
	done
done
