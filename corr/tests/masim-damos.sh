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
	git clone https://github.com/sjp38/masim
	if [ ! -d ./masim ]
	then
		echo "masim clone failed"
		exit $ksft_skip
	fi

	make -C masim -s

	if [ ! -f masim/masim ]
	then
		echo "masim not built"
		exit $ksft_skip
	fi
fi

ETHP=$TEST_DIR/ethp.damos
echo "# format is: <min/max size> <min/max frequency (0-100)> <min/max age> <action>

2M      max    5       max     1s      max    hugepage
2M      max    min     5       1s      max    nohugepage" > $ETHP

DAMO=../../../damon/damo

for pattern in stairs zigzag
do
	$DAMO schemes -c $ETHP "./masim/masim masim/configs/$pattern.cfg"
	if [ $? -ne 0 ]
	then
		echo "applying scheme for $pattern is wrong"
		exit 1
	fi
done
