#!/bin/bash

input_file=$1/kdamond_cpu_usage
out_file=$2/kdamond_cpu_util_rate

if [ $(wc -l < "$input_file") = "0" ]
then
	cpu_util_rate="0"
else
	cpu_util_rate=$(tail -n 1 "$input_file" | awk '{print $1}')
fi
echo "cpu_util_rate: $cpu_util_rate" > "$out_file"
