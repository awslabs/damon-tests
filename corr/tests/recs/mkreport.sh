#!/bin/bash

BINDIR=`dirname $0`

if [ $# -ne 2 ]
then
	echo "Usage: $0 <results dir> <reports dir>"
	exit 1
fi

results_dir=$1
reports_dir=$2

for f in `find $results_dir -name damon.data`
do
	$BINDIR/_mkreport.sh $f $reports_dir
done

images="heatmap.0 heatmap.1 heatmap.2 "
images+="nr_regions_sz nr_regions_time wss_sz wss_time"

cd $reports_dir

for img in $images
do
	html="$img.html"
	echo > $html
	img+=".png"
	for f in `find . -name $img`
	do
		workload=$(basename $(dirname $f))
		category=$(basename $(dirname $(dirname $f)))
		echo "<table style=\"float: left;\">" >> $html
		echo "<tr><td><center>" >> $html
		echo "$category/$workload" >> $html
		echo "<br>" >> $html
		echo "<img src=$f>" >> $html
		echo "</td></tr></table>" >> $html
	done
done

index="index.html"
echo > $index
for html in `find . -name '*.html' | sort`
do
	echo "<a href="$html">$html</a>" >> $index
	echo "<br>" >> $index
done
