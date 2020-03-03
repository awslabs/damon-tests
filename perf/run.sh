#!/bin/bash

LBX=$HOME/lazybox
BINDIR=`dirname $0`

if [ -z "$CFG" ]
then
	CFG=$BINDIR/full_config.sh
fi

time CFG=$CFG $LBX/repeat_runs/run.sh
