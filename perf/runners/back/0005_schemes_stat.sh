#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

SCHEMES="/sys/kernel/debug/damon/schemes"

if [ ! -f $SCHEMES ]
then
	echo "no $SCHEMES" > $1/schemes
fi

while :
do
	cat $SCHEMES >> $1/schemes
	sleep 1
done
