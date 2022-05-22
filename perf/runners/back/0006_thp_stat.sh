#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

while :
do
	grep thp /proc/vmstat >> $1/thpstat;
	sleep 1;
done
