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
