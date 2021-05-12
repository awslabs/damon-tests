#!/bin/bash

input_file="$1/pgmajfaults"
out_file="$2/pgmajfaults"

if [ $(wc -l < "$input_file") = "0" ]
then
	pgmajfaults="0"
else
	start=$(head -n 1 "$input_file" | awk '{print $2}')
	end=$(tail -n 1 "$input_file" | awk '{print $2}')
fi

echo "pgmajfaults: $((end - start))" > "$out_file"
