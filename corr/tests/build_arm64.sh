#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Test arm64 build failure problem reported by kbuild robot

LINUX_SRC='../../../../'
TESTDIR=$PWD
ODIR=$TESTDIR/`basename $0`.out

mkdir -p bin
PATH=$TESTDIR/bin/lkp-tests/kbuild/:$PATH

if [ ! -x ./bin/lkp-tests/kbuild/make.cross ]
then
	git clone https://github.com/intel/lkp-tests ./bin/lkp-tests
	# By default make.cross compiles kernel with strict compiler flags on
	# top. To disable them and make a regular kernel build, edit or erase
	# extra flags in kbuld-kcflags file:
	# echo "" > ./bin/lkp-tests/kbuild/etc/kbuild-kcflags
	chmod +x ./bin/lkp-tests/kbuild/make.cross
fi

mkdir -p $ODIR

cd $LINUX_SRC
make O=$ODIR ARCH=arm64 allnoconfig
cat "$TESTDIR/damon_config" >> $ODIR/.config

export COMPILER_INSTALL_PATH=$HOME/0day
export COMPILER=gcc-9.3.0
export ARCH=arm64
export URL=https://cdn.kernel.org/pub/tools/crosstool/files/bin/x86_64/9.3.0

make.cross O=$ODIR olddefconfig
make.cross O=$ODIR -j$(nproc)
exit $?
