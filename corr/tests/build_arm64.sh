#!/bin/bash

# Test arm64 build failure problem reported by kbuild robot

LINUX_SRC='../../../../'
TESTDIR=$PWD
ODIR=$TESTDIR/`basename $0`.out

mkdir -p bin
PATH=$TESTDIR/bin/:$PATH

if [ ! -x ./bin/make.cross ]
then
	wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ./bin/make.cross
	chmod +x ./bin/make.cross
fi

mkdir -p $ODIR

cd $LINUX_SRC
make O=$ODIR ARCH=arm64 allnoconfig
echo 'CONFIG_DAMON=y' >> $ODIR/.config
echo 'CONFIG_DAMON_KUNIT_TEST=y' >> $ODIR/.config
echo 'CONFIG_DAMON_VADDR=y' >> $ODIR/.config
echo 'CONFIG_DAMON_PADDR=y' >> $ODIR/.config
echo 'CONFIG_DAMON_PGIDLE=y' >> $ODIR/.config
echo 'CONFIG_DAMON_VADDR_KUNIT_TEST=y' >> $ODIR/.config
echo 'CONFIG_DAMON_DBGFS=y' >> $ODIR/.config
echo 'CONFIG_DAMON_DBGFS_KUNIT_TEST=y' >> $ODIR/.config
echo 'CONFIG_DAMON_RECLAIM=y' >> $ODIR/.config

export COMPILER_INSTALL_PATH=$HOME/0day
export COMPILER=gcc-9.3.0
export ARCH=arm64

make.cross O=$ODIR olddefconfig
make.cross O=$ODIR -j$(nproc)
exit $?
