#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: $0 <number> <file>"
	echo
	echo "Get average of <number>-th field of <file>'s contents"
	exit 1
fi

field_idx=$1
data_file=$2

nr=0
sum=0
for data in $(awk -v n="$field_idx" '{print $n}' "$data_file")
do
	sum=$((sum + $data))
	nr=$((nr + 1))
done
echo $((sum / nr))
