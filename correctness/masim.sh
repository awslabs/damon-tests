#!/bin/bash

CDIR=`pwd`

BINDIR=`dirname $0`
cd $BINDIR

source ./__common.sh

DAMO=$KDIR/tools/damon/damo

MCFG=`dirname $MASIM`/configs/

for pattern in stairs zigzag
do
	sudo $DAMO record -o $CDIR/$pattern.data "$MASIM $MCFG/$pattern.cfg"
done
