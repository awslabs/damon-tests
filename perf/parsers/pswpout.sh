#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

LBX="$(dirname "$0")/../../../lazybox"
PSWPOUT=$1/pswpout

$LBX/scripts/report/recs_to_diff.py $PSWPOUT > $2/pswpout.diff
NR_SWPOUT=0
TOTAL_SWPOUT=0
for swpout in `awk '{print $2}' $2/pswpout.diff`
do
	TOTAL_SWPOUT=$(($TOTAL_SWPOUT + $swpout))
	NR_SWPOUT=$(($NR_SWPOUT + 1))
done
echo "swpout.avg: " $(($TOTAL_SWPOUT / $NR_SWPOUT)) > $2/pswpout.avg
