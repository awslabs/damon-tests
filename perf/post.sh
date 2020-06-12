#!/bin/bash

LBX=$HOME/lazybox
BINDIR=`dirname $0`

if [ -z "$CFG" ] || [ ! -f "$CFG" ]
then
	echo "Set 'CFG' env variable to proper config, please"
	exit 1
fi

time CFG=$CFG $LBX/repeat_runs/post.sh
