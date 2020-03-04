#!/bin/bash

BINDIR=`dirname $0`
FMT=$HOME/lazybox/scripts/report/fmt_tbl.py
REPORT_DIR=report/

$BINDIR/_plot_numbers.sh $REPORT_DIR/plots

$BINDIR/_pr_report.sh | $FMT --stdin > $REPORT_DIR/report.txt

for metric in runtime memused.avg
do
	$BINDIR/_pr_metrics_overheads.sh avg $metric | $FMT --stdin
	echo
	echo
done
