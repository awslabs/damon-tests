#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

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
cat "$TESTDIR/damon_config" >> $ODIR/.config

export COMPILER_INSTALL_PATH=$HOME/0day
export COMPILER=gcc-9.3.0
export ARCH=arm64

make.cross O=$ODIR olddefconfig
make.cross O=$ODIR -j$(nproc)
exit $?
