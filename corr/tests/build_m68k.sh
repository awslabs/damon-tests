#!/bin/bash

# Test m68k build failure problem reported[1] by kbuild robot
#
# [1] https://lore.kernel.org/linux-mm/202002130710.3P1Y98f7%25lkp@intel.com/

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
make O=$ODIR ARCH=m68k allnoconfig
echo 'CONFIG_MODULES=y' >> $ODIR/.config
echo 'CONFIG_DAMON=m' >> $ODIR/.config

export COMPILER_INSTALL_PATH=$HOME/0day
export GCC_VERSION=7.5.0

make.cross O=$ODIR ARCH=m68k olddefconfig
make.cross O=$ODIR ARCH=m68k -j`grep -e '^processor' /proc/cpuinfo | wc -l`
exit $?
