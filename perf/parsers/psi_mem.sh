#!/bin/bash

psi_mem_log="$1/psi_mem"
out_dir="$2"

# example content of log:
# some avg10=0.00 avg60=0.00 avg300=0.00 total=0
# full avg10=0.00 avg60=0.00 avg300=0.00 total=0
# some avg10=0.00 avg60=0.00 avg300=0.00 total=0
# full avg10=0.00 avg60=0.00 avg300=0.00 total=0
# some avg10=0.00 avg60=0.00 avg300=0.00 total=4278
# [...]

some_start=$(head -n 1 "$psi_mem_log" | awk -F '=' '{print $5}')
full_start=$(head -n 2 "$psi_mem_log" | tail -n 1 | awk -F '=' '{print $5}')
some_end=$(tail -n 2 "$psi_mem_log" | head -n 1 | awk -F '=' '{print $5}')
full_end=$(tail -n 1 "$psi_mem_log" | awk -F '=' '{print $5}')

echo "ps_mem_some_us: $((some_end - some_start))" > "$out_dir/psi_mem_some_us"
echo "ps_mem_full_us: $((full_end - full_start))" > "$out_dir/psi_mem_full_us"
