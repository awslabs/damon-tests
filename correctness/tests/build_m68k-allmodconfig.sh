#!/bin/bash

ksft_skip=4

LINUX_SRC='../../../../'
TESTDIR=$PWD
CONFIG=m68k-allmodconfig.config
ODIR=$TESTDIR/$CONFIG.out

mkdir -p bin
PATH=$TESTDIR/bin/:$PATH

wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ./bin/make.cross
chmod +x ./bin/make.cross

mkdir -p $ODIR
cp $CONFIG $ODIR/.config

cd $LINUX_SRC
GCC_VERSION=7.5.0 make.cross ARCH=m68k O=$ODIR
