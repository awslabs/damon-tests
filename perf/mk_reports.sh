#!/bin/bash

LC_NUMERIC="en_US.UTF-8"

BINDIR=`dirname $0`
FMT="$HOME/lazybox/scripts/report/fmt_tbl.py --spaces 1 "
REPORT_DIR=report/

if [ -z "$CFG" ] || [ ! -f "$CFG" ]
then
	echo "Set 'CFG' env variable to proper config, please"
	exit 1
fi

$BINDIR/_plot_numbers.sh $REPORT_DIR/plots

$BINDIR/_pr_report.sh | $FMT > $REPORT_DIR/report.txt

for metric in runtime memused.avg rss.avg
do
	$BINDIR/_summary_results.sh avg $metric | $FMT
	echo
	echo
done

HTMLDIR=$REPORT_DIR/html/
mkdir -p $HTMLDIR
HTML=$HTMLDIR/index.html
echo > $HTML

for metric in runtime memused.avg rss.avg
do
	echo "<img src=../plots/$metric.png />" >> $HTML
done

echo "<br><br>" >> $HTML
echo "<pre>" >> $HTML
cat $REPORT_DIR/report.txt >> $HTML
echo "</pre>" >> $HTML
