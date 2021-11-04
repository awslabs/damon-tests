#!/bin/bash

dmesg -C

./huge_count_read_write

if dmesg | grep -q WARNING
then
	dmesg
	exit 1
else
	exit 0
fi
