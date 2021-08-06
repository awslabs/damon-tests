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
	exit "$ksft_skip"
fi

ETHP=$TEST_DIR/ethp.damos
echo "# format is: <min/max size> <min/max frequency (0-100)> <min/max age> <action>

2M      null    5       null    1s      null    hugepage
2M      null    null    5       1s      null    nohugepage" > $ETHP

DAMO=./damo/damo

if [ ! -f $DAMO ]
then
	echo "damo not installed?"
	exit "$ksft_skip"
fi

for pattern in stairs zigzag
do
	$DAMO record "./masim/masim masim/configs/$pattern.cfg"
	if [ ! -f damon.data ]
	then
		echo "damon.data for $pattern not found"
		exit 1
	fi
	if [ -f ../damon/_chk_record.py ]
	then
		python3 ../damon/_chk_record.py damon.data
		if [ $? -ne 0 ]
		then
			echo "record file for $pattern is wrong"
			exit 1
		fi
	fi

	if [ "$pattern" == "stairs" ]
	then
		min_wss=9000000
		max_wss=11000000
	elif [ "$pattern" == "zigzag" ]
	then
		min_wss=90000000
		max_wss=110000000
	fi
	wss=$($DAMO report wss --raw_number --range 50 51 1 | \
		grep -e "^ 50" | awk '{print $2}')
	if [ "$wss" -lt "$min_wss" ] || [ "$wss" -gt "$max_wss" ]
	then
		echo "unexpected wss for $pattern: $wss"
		exit 1
	else
		echo "expected wss for $pattern: $min_wss <= $wss <= $max_wss"
	fi
done
