#!/bin/bash

LBX=$HOME/lazybox
BINDIR=`dirname $0`

time CFG=$BINDIR/full_config.sh $LBX/repeat_runs/run.sh
