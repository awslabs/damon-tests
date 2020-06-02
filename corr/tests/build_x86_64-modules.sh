#!/bin/bash

# Test x86 build failure problem reported[1] by kbuild robot
#
# [1] https://lore.kernel.org/linux-mm/202002140021.Pr9vTFO6%25lkp@intel.com/

LINUX_SRC='../../../../'
ODIR=$PWD/`basename $0`.out

mkdir -p $ODIR

cd $LINUX_SRC
make O=$ODIR ARCH=x86_64 allnoconfig
echo 'CONFIG_DAMON=m' >> $ODIR/.config
echo 'CONFIG_DAMON_KUNIT_TEST=m' >> $ODIR/.config
make O=$ODIR ARCH=x86_64 -j`grep -e '^processor' /proc/cpuinfo | wc -l`
exit $?
