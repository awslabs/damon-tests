#!/bin/bash

BINDIR=`dirname $0`
LOG=$PWD/log

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
cp ./tests/* $ksft_abs_path

# run
cd $LINUX_DIR
make -silent -C $ksft_dir/../damon run_tests | tee $LOG
make -silent -C $ksft_dir/ run_tests | tee -a $LOG

# print results
echo
grep -q -e '^not ok' $LOG
if [ $? -ne 0 ]
then
	echo -e "\e[92mPASS"
else
	echo -e "\e[93mFailed tests:"
	grep -e '^not ok' $LOG
	echo
	echo -e "\e[91mFAIL"
fi
echo -e "\e[39m"

echo "# kselftest dir '$ksft_abs_path' is in dirty state."
echo "# the log is at '$LOG'."
