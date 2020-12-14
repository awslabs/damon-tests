#!/bin/bash

TEST_DIR=$PWD
KUNIT_BDIR=$TEST_DIR/kunit.out
KUNITCONFIG=$KUNIT_BDIR/.kunitconfig

mkdir -p $KUNIT_BDIR

if [ ! -f $KUNITCONFIG ]; then
	echo "
	CONFIG_KUNIT=y

	CONFIG_DAMON=y
	CONFIG_DAMON_KUNIT_TEST=y

	CONFIG_DAMON_VADDR=y
	CONFIG_DAMON_VADDR_KUNIT_TEST=y

	CONFIG_DEBUG_FS=y
	CONFIG_DAMON_PADDR=y
	CONFIG_DAMON_DBGFS=y
	CONFIG_DAMON_DBGFS_KUNIT_TEST=y" > $KUNITCONFIG
fi

# we are in tools/testing/selftests/damon-tests/
cd ../../../../
./tools/testing/kunit/kunit.py run --build_dir $KUNIT_BDIR
