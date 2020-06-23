#!/bin/bash

total=0
nr_items=0
for rss in `awk '{print $2}' $1/memfps`
do
	total=$(($total + $rss))
	nr_items=$(($nr_items + 1))
done
echo "rss.avg: " $(($total / $nr_items)) > $2/rss.avg
