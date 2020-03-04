#!/bin/bash

BINDIR=`dirname $0`
LBX=$HOME/lazybox
PLOT=$LBX/gnuplot/plot.py

REPORTS_DIR=reports/plots/
mkdir -p $REPORTS_DIR

for metric in runtime memused.avg
do
	OUTPUT_IMG=$REPORTS_DIR/$metric.pdf
	$BINDIR/_pr_overheads.sh avg $metric | \
		$PLOT --stdin --type clustered_boxes --xtics_rotate -90 \
			--ytitle "$metric overhead\n(percent)" \
			--font "Times New Roman" \
			$OUTPUT_IMG
	if [ $? -eq 0 ]
	then
		echo "'$OUTPUT_IMG' generated"
	fi
done
