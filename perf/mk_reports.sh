#!/bin/bash

BINDIR=`dirname $0`
FMT="$HOME/lazybox/scripts/report/fmt_tbl.py --spaces 1 --stdin"
REPORT_DIR=report/

$BINDIR/_plot_numbers.sh $REPORT_DIR/plots

$BINDIR/_pr_report.sh | $FMT --stdin > $REPORT_DIR/report.txt

for metric in runtime memused.avg
do
	$BINDIR/_summary_results.sh avg $metric | $FMT
	echo
	echo
done

HTMLDIR=$REPORT_DIR/html/
mkdir -p $HTMLDIR
HTML=$HTMLDIR/index.html
echo > $HTML

for metric in runtime memused.avg
do
	echo "<img src=../plots/$metric.png />" >> $HTML
done

echo "<br><br>" >> $HTML
echo "<pre>" >> $HTML
cat $REPORT_DIR/report.txt >> $HTML
echo "</pre>" >> $HTML
