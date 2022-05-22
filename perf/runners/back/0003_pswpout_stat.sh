#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

while :
do
	cat /proc/vmstat | grep pswpout >> $1/pswpout;
	sleep 1;
done
