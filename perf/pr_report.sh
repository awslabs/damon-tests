#!/bin/bash

BINDIR=`dirname $0`

echo "======="
echo "Summary"
echo "======="
echo

for metric in runtime memused.avg
do
	$BINDIR/_pr_metrics_overheads.sh avg $metric
	echo
	echo
done

echo "==========="
echo "Raw Numbers"
echo "==========="
echo

for stat in avg stdev min max
do
	for metric in runtime memused.avg
	do
		$BINDIR/_pr_metrics.sh $stat $metric
		echo
		echo
	done
done
