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

2M      null    5       null    1s      null    hugepage
2M      null    null    5       1s      null    nohugepage" > $ETHP

DAMO=../../../damon/damo

for pattern in stairs zigzag
do
	$DAMO record "./masim/masim masim/configs/$pattern.cfg"
	if [ ! -f damon.data ]
	then
		echo "damon.data for $pattern not found"
		exit 1
	fi
	python3 ../damon/_chk_record.py damon.data
	if [ $? -ne 0 ]
	then
		echo "record file for $pattern is wrong"
		exit 1
	fi
done
