#!/bin/bash

dmesg -C

python -c 'print("1024 " + "A" * 1024)' > /sys/kernel/debug/damon/record

log=$(dmesg)

if [ "$log" = "" ]
then
	exit 0
else
	dmesg
	exit 1
fi
