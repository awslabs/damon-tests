#!/bin/bash

BINDIR=`dirname $0`
cd $BINDIR

source ./__common.sh

if [ ! -d $KDIR ]
then
	echo "$KDIR found"
	exit 1
fi

if [ ! -f $MASIM ]
then
	MASIMDIR=`dirname $MASIM`
	git clone https://github.com/sjp38/masim $MASIMDIR
	make -C $MASIMDIR -s

	if [ ! -f $MASIM ]
	then
		echo "masim not built"
		exit 1
	fi
fi

exit 0
