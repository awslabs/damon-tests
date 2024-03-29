#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

EXPERIMENTS=`dirname $BASH_SOURCE`

parsec_workloads="blackscholes bodytrack canneal dedup facesim "
parsec_workloads+="fluidanimate freqmine raytrace streamcluster swaptions "
parsec_workloads+="vips"

splash2x_workloads="barnes fft lu_cb lu_ncb ocean_cp radiosity "
splash2x_workloads+="radix raytrace volrend water_nsquared water_spatial"

workloads=""
for w in $parsec_workloads
do
	workloads+="parsec3/$w "
done

for w in $splash2x_workloads
do
	workloads+=" splash2x/$w"
done

vars="orig rec prec thp ethp prcl_auto_50 pdarc_v4_2_2 ttmo plrus_auto_7000"

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
REPEATS=1
