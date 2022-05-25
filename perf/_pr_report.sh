#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

BINDIR=`dirname $0`
LBX="$(dirname "$0")/../../lazybox"

echo "======="
echo "Summary"
echo "======="
echo

for metric in runtime kdamond_cpu_util memused.avg rss.avg pgmajfaults psi_mem_some_us
do
	$BINDIR/_summary_results.sh avg $metric | "$LBX/scripts/report/fmt_tbl.py"
	echo
	echo
done

echo "====="
echo "Stats"
echo "====="
echo

for stat in avg stdev min max
do
	for metric in runtime kdamond_cpu_util memused.avg rss.avg pgmajfaults psi_mem_some_us
	do
		$BINDIR/_pr_metrics.sh $stat $metric
		echo
		echo
	done
done
