#!/bin/bash

BINDIR=`dirname $0`
LBX=$HOME/lazybox
PLOT=$LBX/gnuplot/plot.py

REPORTS_DIR=reports
mkdir -p $REPORTS_DIR

for metric in runtime memused.avg
do
	$BINDIR/_pr_overheads.sh avg $metric | \
		$PLOT --stdin --type clustered_boxes --xtics_rotate -90 \
			--ytitle "$metric overhead (percent)" \
			$REPORTS_DIR/$metric.pdf
done

evince reports/*.pdf
