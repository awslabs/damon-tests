#!/bin/bash

while :
do
	cat /proc/meminfo | grep MemAvailable >> $1/memavail;
	cat /proc/meminfo | grep SwapCached >> $1/swapcached;
	sleep 1;
done
