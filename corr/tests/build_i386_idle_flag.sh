#!/bin/bash

# Test i386 build failure problem reported[1] by kbuild robot
#
# [1] https://lore.kernel.org/linux-mm/202002051834.cKoViGVl%25lkp@intel.com/

LINUX_SRC='../../../../'
TESTDIR=$PWD
ODIR=$PWD/`basename $0`.out

mkdir -p $ODIR

cd $LINUX_SRC
make O=$ODIR ARCH=i386 allnoconfig
cat "$TESTDIR/damon_config" >> "$ODIR/.config"
echo 'CONFIG_PAGE_IDLE_FLAG=y' >> $ODIR/.config
make O=$ODIR ARCH=i386 olddefconfig
make O=$ODIR ARCH=i386 -j`grep -e '^processor' /proc/cpuinfo | wc -l`
exit $?
