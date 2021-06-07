#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <path to kernel source code>"
	exit 1
fi

BINDIR=`dirname $0`

target_dir=$1/tools/testing/selftests/damon-tests

mkdir -p $target_dir
cp $BINDIR/tests/* $target_dir

cd "$target_dir"
if [ ! -d "damo" ]
then
	git clone https://github.com/awslabs/damo
	if [ ! -d ./damo ]
	then
		echo "damo clone failed"
		exit 1
	fi
fi

if [ ! -d "masim" ]
then
	git clone https://github.com/sjp38/masim
	if [ ! -d ./masim ]
	then
		echo "masim clone failed"
		exit 1
	fi

	make -C masim -s

	if [ ! -f masim/masim ]
	then
		echo "masim not built"
		exit 1
	fi
fi
