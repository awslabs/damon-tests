#!/bin/bash

EXPERIMENTS=`dirname $BASH_SOURCE`

parsec_workloads="fluidanimate freqmine streamcluster"

splash2x_workloads="fft ocean_ncp radiosity"

workloads=""
for w in $parsec_workloads
do
	workloads+="parsec3/$w "
done

for w in $splash2x_workloads
do
	workloads+=" splash2x/$w"
done

vars="orig rec thp ethp prcl"

VARIANTS=""

for v in $vars
do
	for w in $workloads
	do
		VARIANTS+="$w/$v "
	done
done

EXPERIMENTS=$EXPERIMENTS
VARIANTS=$VARIANTS
REPEATS=5
