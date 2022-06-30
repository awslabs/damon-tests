#!/bin/bash

# $1: <...>/results/<exp>/<variance>/0(0-9)
bindir=$(dirname "$0")
odir=$1
var=$(basename $(dirname "$odir"))

if [ ! "$var" = "ttmo" ] && [[ ! "$var" == "plrus-"* ]]
then
	exit 0
fi

# for paper default param, it should be
# "$bindir/_ttmo.sh" 5 10 6000
# we use 10% reclaim_ratio, 1% PSI threshold, 1 sec reclaim interval
"$bindir/_ttmo.sh" 1000 100 1000
