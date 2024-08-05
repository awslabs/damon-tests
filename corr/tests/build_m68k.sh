#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Test m68k build failure problem reported[1] by kbuild robot
#
# [1] https://lore.kernel.org/linux-mm/202002130710.3P1Y98f7%25lkp@intel.com/

LINUX_SRC='../../../../'
TESTDIR=$PWD
ODIR=$TESTDIR/`basename $0`.out

mkdir -p bin
PATH=$TESTDIR/bin/:$PATH

PATH=$TESTDIR/bin/lkp-tests/kbuild/:$PATH

if [ ! -x ./bin/lkp-tests/kbuild/make.cross ]
then
	git clone https://github.com/intel/lkp-tests ./bin/lkp-tests
	# Disable restricted kernel compilation flags
	echo "" > ./bin/lkp-tests/kbuild/etc/kbuild-kcflags
	chmod +x ./bin/lkp-tests/kbuild/make.cross
fi

mkdir -p $ODIR

cd $LINUX_SRC
make O=$ODIR ARCH=m68k allnoconfig
echo 'CONFIG_MODULES=y' >> $ODIR/.config
cat "$TESTDIR/damon_config" >> "$ODIR/.config"

export COMPILER_INSTALL_PATH=$HOME/0day
export COMPILER=gcc-7.5.0
export URL=https://cdn.kernel.org/pub/tools/crosstool/files/bin/x86_64/7.5.0

make.cross O=$ODIR ARCH=m68k olddefconfig
make.cross O=$ODIR ARCH=m68k -j`grep -e '^processor' /proc/cpuinfo | wc -l`
exit $?
