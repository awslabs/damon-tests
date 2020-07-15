#!/bin/bash

while :
do
	grep thp /proc/vmstat >> $1/thpstat;
	sleep 1;
done
