#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

EXPERIMENTS=`dirname $BASH_SOURCE`/../../../perf

parsec_workloads="blackscholes bodytrack canneal dedup facesim ferret "
parsec_workloads+="fluidanimate freqmine raytrace streamcluster swaptions "
parsec_workloads+="vips x264"

splash2x_workloads="barnes fft lu_cb lu_ncb ocean_cp ocean_ncp radiosity "
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

vars="rec"

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
