#!/bin/bash

BINDIR=`dirname $0`
LOG=$PWD/log

repos_dir=$(realpath "$BINDIR/../../")

if [ -z $LINUX_DIR ]
then
	LINUX_DIR="$repos_dir/linux"
fi

if [ ! -d $LINUX_DIR ]
then
	echo "linux source directory not found at $LINUX_DIR"
	exit 1
fi

ksft_dir=tools/testing/selftests/damon-tests
ksft_abs_path=$LINUX_DIR/$ksft_dir

mkdir -p "$ksft_abs_path"

damo_dir="$repos_dir/damo"
if [ ! -x "$damo_dir/damo" ]
then
	echo "damo at $damo_dir/damo not found"
	exit 1
fi
cp -R "$damo_dir" "$ksft_abs_path/"

masim_dir="$repos_dir/masim"
if [ ! -x "$masim_dir/masim" ]
then
	echo "masim at $masim_dir/masim not found"
	exit 1
fi
cp -R "$masim_dir" "$ksft_abs_path/"

# run
(
	cd $LINUX_DIR
	make --silent -C $ksft_dir/../damon run_tests | tee $LOG
	make --silent -C $ksft_dir/ run_tests | tee -a $LOG

	echo "# kselftest dir '$ksft_abs_path' is in dirty state."
	echo "# the log is at '$LOG'."
)

# print results
if ! $BINDIR/_summary_results.sh $LOG
then
	exit 1
fi
