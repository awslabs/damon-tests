#!/bin/bash

while :
do
	cat /proc/meminfo | grep MemAvailable >> $1/memavail;
	cat /proc/meminfo | grep SwapCached >> $1/swapcached;
	grep pgfault /proc/vmstat >> "$1/pgfaults"
	grep pgmajfault /proc/vmstat >> "$1/pgmajfaults"
	sleep 1;
done
