#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

echo "Run damon-tests/corr on $(uname -r) kernel"

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

"$BINDIR/install_deps.sh"

ksft_dir=tools/testing/selftests/damon-tests
ksft_abs_path=$LINUX_DIR/$ksft_dir

mkdir -p "$ksft_abs_path"
cp "$BINDIR"/tests/* "$ksft_abs_path/"

damo_dir="$repos_dir/damo"
if [ ! -x "$damo_dir/damo" ]
then
	echo "damo at $damo_dir/damo not found"
	exit 1
fi
rm -fr "$ksft_abs_path/damo"
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

	# commit 44ee9ff07fd7 ("selftests: error out if kernel header files are
	# not yet built") made 'make headers' required for kselftest in
	# general.  Respect the requirement.
	linux_build_output="$ksft_abs_path/linux_build_output"
	make O="$linux_build_output" headers
	export KBUILD_OUTPUT="$linux_build_output"

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
