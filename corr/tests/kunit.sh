#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

ksft_skip=4

# we are in tools/testing/selftests/damon-tests/
if [ ! -f ../../kunit/kunit.py ]
then
	echo "kunit.py not found"
	exit "$ksft_skip"
fi

TEST_DIR=$PWD
KUNIT_BDIR=$TEST_DIR/kunit.out

rm -fr "$KUNIT_BDIR"
mkdir -p $KUNIT_BDIR

if [ -f ../../../../mm/damon/tests/.kunitconfig ]
then
	# we are in tools/testing/selftests/damon-tests/
	cd ../../../../
	./tools/testing/kunit/kunit.py run --kunitconfig=mm/damon/tests \
		--build_dir $KUNIT_BDIR
	exit $?
fi


KUNITCONFIG=$KUNIT_BDIR/.kunitconfig
echo "
CONFIG_KUNIT=y

CONFIG_DAMON=y
CONFIG_DAMON_KUNIT_TEST=y

CONFIG_DAMON_VADDR=y
CONFIG_DAMON_VADDR_KUNIT_TEST=y

CONFIG_DEBUG_FS=y
CONFIG_DAMON_DBGFS=y
CONFIG_DAMON_DBGFS_KUNIT_TEST=y
" > $KUNITCONFIG

# kunit compilation could fail due to wrong config
if [ -f ../../../../mm/damon/sysfs-test.h ]
then
	echo "
	CONFIG_DAMON_SYSFS=y
	CONFIG_DAMON_SYSFS_KUNIT_TEST=y
	" >> $KUNITCONFIG
fi

if grep --quiet DAMON_DBGFS_DEPRECATED ../../../../mm/damon/Kconfig
then
	echo "
	CONFIG_DAMON_DBGFS_DEPRECATED=y
	" >> $KUNITCONFIG
fi

# we are in tools/testing/selftests/damon-tests/
cd ../../../../

# After paddr.c introduction, DAMON_DEBUGFS depends on DAMON_PADDR
if [ -f "./mm/damon/paddr.c" ]
then
	echo "CONFIG_DAMON_PADDR=y" >> "$KUNITCONFIG"
fi
./tools/testing/kunit/kunit.py run --build_dir $KUNIT_BDIR
