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

DAMO=../../../damon/damo

for pattern in stairs zigzag
do
	$DAMO record "./masim/masim masim/configs/$pattern.cfg"
done
