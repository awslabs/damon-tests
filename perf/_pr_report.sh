#!/bin/bash

BINDIR=`dirname $0`

echo "======="
echo "Summary"
echo "======="
echo

for metric in runtime kdamond_cpu_util memused.avg rss.avg pgmajfaults
do
	$BINDIR/_summary_results.sh avg $metric
	echo
	echo
done

echo "====="
echo "Stats"
echo "====="
echo

for stat in avg stdev min max
do
	for metric in runtime kdamond_cpu_util memused.avg rss.avg pgmajfaults
	do
		$BINDIR/_pr_metrics.sh $stat $metric
		echo
		echo
	done
done
