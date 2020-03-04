#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <image output dir>"
	exit 1
fi

ODIR=$1

BINDIR=`dirname $0`
LBX=$HOME/lazybox
PLOT=$LBX/gnuplot/plot.py

mkdir -p $ODIR

for metric in runtime memused.avg
do
	OUTPUT_IMG=$ODIR/$metric.pdf
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
