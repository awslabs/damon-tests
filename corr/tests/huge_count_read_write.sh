#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

set -e

dmesg -C

for file in /sys/kernel/debug/damon/*
do
	./huge_count_read_write "$file"
done

if dmesg | grep -q WARNING
then
	dmesg
	exit 1
else
	exit 0
fi
