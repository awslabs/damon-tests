#!/bin/bash

ksft_skip=4

TEST_DIR=$PWD

if [ $EUID -ne 0 ]
then
	echo "Run as root"
	exit $ksft_skip
fi

if [ ! -d ./masim ]
then
	echo "masim not installed?"
	exit $ksft_skip
fi

ETHP=$TEST_DIR/ethp.damos
echo "# format is: <min/max size> <min/max frequency (0-100)> <min/max age> <action>

2M      max    5       max     1s      max    hugepage
2M      max    min     5       1s      max    nohugepage" > $ETHP

DAMO=./damo/damo

if [ ! -f "$DAMO" ]
then
	echo "DAMO not installed?"
	exit $ksft_skip
fi

for pattern in stairs_30secs zigzag_30secs
do
	$DAMO schemes -c $ETHP "./masim/masim masim/configs/$pattern.cfg"
	if [ $? -ne 0 ]
	then
		echo "applying scheme for $pattern is wrong"
		exit 1
	fi
done
