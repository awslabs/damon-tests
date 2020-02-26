#!/bin/bash

BINDIR=`dirname $0`

if [ -z $LINUX_DIR ]
then
	LINUX_DIR=$HOME/linux
fi

if [ ! -d $LINUX_DIR ]
then
	echo "linux source directory not found at $LINUX_DIR"
	exit 1
fi

ksft_dir=tools/testing/selftests/damon-tests
ksft_abs_path=$LINUX_DIR/$ksft_dir

# install
mkdir -p $ksft_abs_path
cp ./* $ksft_abs_path
cp ./Makefile.kselftest $ksft_abs_path/Makefile

# run
cd $LINUX_DIR
make -C $ksft_dir/../ TARGETS="damon-tests damon" run_tests

if [ $? -eq 0 ]
then
	echo -e "\e[92mPASS"
else
	echo -e "\e[91mFAIL"
fi
echo -e "\e[39m"

echo "# $ksft_abs_path is in dirty state now, remove it if you don't want so"
