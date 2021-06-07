#!/bin/bash

ksft_skip=4

if [ $EUID -ne 0 ]
then
	echo "Run as root"
	exit $ksft_skip
fi

if [ ! -d ./damo ]
then
	git clone https://github.com/awslabs/damo
	if [ ! -d ./damo ]
	then
		echo "damo clone failed"
		exit $ksft_skip
	fi
fi

./damo/tests/run.sh
