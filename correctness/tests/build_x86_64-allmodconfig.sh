#!/bin/bash

ksft_skip=4

LINUX_SRC='../../../../'
TESTDIR=$PWD
CONFIG=x86_64-allmodconfig.config
ODIR=$TESTDIR/$CONFIG.out

mkdir -p $ODIR
cp $CONFIG $ODIR/.config

cd $LINUX_SRC
make O=$ODIR ARCH=x86_64 -j`grep -e '^processor' /proc/cpuinfo | wc -l`
