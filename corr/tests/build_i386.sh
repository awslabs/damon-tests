#!/bin/bash

# Test i386 build failure problem reported[1] by kbuild robot
#
# [1] https://lore.kernel.org/linux-mm/202002051834.cKoViGVl%25lkp@intel.com/

LINUX_SRC='../../../../'
ODIR=$PWD/`basename $0`.out

mkdir -p $ODIR

cd $LINUX_SRC
make O=$ODIR ARCH=i386 allnoconfig
echo 'CONFIG_DAMON=y' >> $ODIR/.config
echo 'CONFIG_DAMON_KUNIT_TEST=y' >> $ODIR/.config
echo 'CONFIG_DAMON_VADDR=y' >> $ODIR/.config
echo 'CONFIG_DAMON_PADDR=y' >> $ODIR/.config
echo 'CONFIG_DAMON_PGIDLE=y' >> $ODIR/.config
echo 'CONFIG_DAMON_VADDR_KUNIT_TEST=y' >> $ODIR/.config
echo 'CONFIG_DAMON_DBGFS=y' >> $ODIR/.config
echo 'CONFIG_DAMON_DBGFS_KUNIT_TEST=y' >> $ODIR/.config
echo 'CONFIG_DAMON_RECLAIM=y' >> $ODIR/.config

make O=$ODIR ARCH=i386 olddefconfig
make O=$ODIR ARCH=i386 -j`grep -e '^processor' /proc/cpuinfo | wc -l`
exit $?
