#!/bin/bash

input_file=$1/kdamond_cpu_usage
out_file=$2/kdamond_cpu_util

if [ $(wc -l < "$input_file") = "0" ]
then
	cpu_util="0"
else
	cpu_util=$(tail -n 1 "$input_file" | awk '{print $1}')
fi
echo "cpu_util: $cpu_util" > "$out_file"
