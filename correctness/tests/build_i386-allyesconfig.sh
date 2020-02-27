#!/bin/bash

ksft_skip=4

LINUX_SRC='../../../../'
TESTDIR=$PWD
CONFIG=i386-allyesconfig.config
ODIR=$TESTDIR/$CONFIG.out

mkdir -p bin
PATH=$TESTDIR/bin/:$PATH

mkdir -p $ODIR
cp $CONFIG $ODIR/.config

cd $LINUX_SRC
make O=$ODIR ARCH=i386 -j`grep -e '^processor' /proc/cpuinfo | wc -l`
