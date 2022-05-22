#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

while :
do
	cat /proc/vmstat | grep pswpin >> $1/pswpin;
	sleep 1;
done
