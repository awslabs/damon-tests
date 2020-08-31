#!/bin/bash

DAMO=$HOME/linux/tools/damon/damo

if [ $# -ne 2 ]
then
	echo "Usage: $0 <data file> <reports root dir>"
	exit 1
fi

# data file path: <...>/(parsec3|splash2x)/<workload>/[p]rec/(0-9)+/damon.data
data_file_path=$1
report_dir_root=$2

var=$(basename $(dirname $(dirname $data_file_path)))
workload=$(basename $(dirname $(dirname $(dirname $data_file_path))))
category=$(basename $(dirname $(dirname $(dirname $(dirname $data_file_path)))))
name=$category/$workload/$var
report_dir=$report_dir_root/$name
html=$report_dir/report.html

if [ -d $report_dir ]
then
	echo "the report already exists at $report_dir"
	exit 1
fi

mkdir -p $report_dir

echo $name'<br>' > $html

in='-i '$data_file_path
echo "<pre>" >> $html
guide=`$DAMO report heats $in --guide`
echo $guide >> $html
echo "</pre>" >> $html

regions=`$DAMO report heats $in --guide | grep region | awk '{print $3}'`
idx=0
for region in $regions
do
	saddr=`echo $region | awk -F'-' '{print $1}' | sed 's/^0*//'`
	eaddr=`echo $region | awk -F'-' '{print $2}' | sed 's/^0*//'`
	addr='--amin '$saddr' --amax '$eaddr
	$DAMO report heats $in $addr --heatmap $report_dir/heatmap.$idx.png
	echo "<img src=heatmap.$idx.png />" >> $html
	idx=$(($idx + 1))
done
echo "<br>" >> $html

range='--range 0 101 1'
$DAMO report wss $in --plot $report_dir/wss_sz.png $range
$DAMO report wss $in --sortby time --plot $report_dir/wss_time.png $range
echo "<img src=wss_sz.png />" >> $html
echo "<img src=wss_time.png />" >> $html
echo "<br>" >> $html

$DAMO report nr_regions $in --plot $report_dir/nr_regions_sz.png $range
$DAMO report nr_regions $in --sortby time --plot $report_dir/nr_regions_time.png $range
echo "<img src=nr_regions_sz.png />" >> $html
echo "<img src=nr_regions_time.png />" >> $html

echo "Your report is ready at '$html'"
