#!/bin/bash

while :
do
	grep -m 1 "Active:" /proc/meminfo >> "$1/active_mem"
	grep -m 1 "Inactive:" /proc/meminfo >> "$1/inactive_mem"
	grep -m 1 "Active(anon):" /proc/meminfo >> "$1/active_anon_mem"
	grep -m 1 "Inactive(anon):" /proc/meminfo >> "$1/inactive_anon_mem"
	grep -m 1 "Active(file):" /proc/meminfo >> "$1/active_file_mem"
	grep -m 1 "Inactive(file):" /proc/meminfo >> "$1/inactive_file_mem"
	sleep 1
done
