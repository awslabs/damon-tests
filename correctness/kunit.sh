#!/bin/bash

BINDIR=`dirname $0`
cd $BINDIR

source ./__common.sh

KUNIT_BDIR=$HOME/kunit.out
KUNITCONFIG=$KUNIT_BDIR/.kunitconfig

mkdir -p $KUNIT_BDIR

if [ ! -f $KUNITCONFIG ]; then
	echo "
	CONFIG_KUNIT=y
	CONFIG_DAMON=y
	CONFIG_DAMON_KUNIT_TEST=y" > $KUNITCONFIG
fi

cd $KDIR
./tools/testing/kunit/kunit.py run --build_dir $KUNIT_BDIR
