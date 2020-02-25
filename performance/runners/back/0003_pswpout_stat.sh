#!/bin/bash

while :
do
	cat /proc/vmstat | grep pswpout >> $1/pswpout;
	sleep 1;
done
