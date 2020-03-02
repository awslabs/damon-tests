#!/bin/bash

BINDIR=`dirname $0`

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
