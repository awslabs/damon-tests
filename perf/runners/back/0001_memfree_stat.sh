#!/bin/bash

while :
do
	grep -m 1 MemFree /proc/meminfo >> "$1/memfree"
	grep -m 1 nr_free_pages /proc/vmstat >> "$1/nr_free_pages"
	sleep 1
done
