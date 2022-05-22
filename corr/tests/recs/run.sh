#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

LBX=$HOME/lazybox
BINDIR=`dirname $0`

CFG=$BINDIR/config.sh $LBX/repeat_runs/run.sh
