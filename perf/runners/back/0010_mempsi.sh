#!/bin/bash

while :
do
	cat /proc/pressure/memory >> "$1/psi_mem"
	sleep 1
done
