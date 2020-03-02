#!/bin/bash

BINDIR=`dirname $0`

echo "========="
echo "Overheads"
echo "========="
echo

for stat in avg
do
	for metric in runtime memused.avg
	do
		$BINDIR/_pr_overheads.sh $stat $metric
		echo
		echo
	done
done

echo "==========="
echo "Raw Numbers"
echo "==========="
echo

for stat in avg stdev min max
do
	for metric in runtime memused.avg
	do
		echo "$metric ($stat)"
		echo "================="
		echo
		$BINDIR/_pr_metrics.sh $stat $metric
		echo
		echo
	done
done
