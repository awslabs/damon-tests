#!/bin/bash

BINDIR=`dirname $0`
cd $BINDIR

source ./__common.sh

cd $KDIR
sudo ./tools/testing/selftests/vm/damon_debugfs.sh
exit $?
