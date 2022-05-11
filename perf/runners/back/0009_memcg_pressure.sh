#!/bin/bash

# $1: <...>/results/<exp>/<variance>/0(0-9)
odir=$1
var=$(basename $(dirname "$odir"))

work=$(basename $(dirname $(dirname "$odir")))
work_category=$(basename $(dirname $(dirname $(dirname "$odir"))))

measured_rss_avg="
parsec3/blackscholes  586064.8
parsec3/bodytrack  32426.8
parsec3/canneal  843855.2
parsec3/dedup  1171423.2
parsec3/facesim  311780.6
parsec3/fluidanimate  531966.4
parsec3/freqmine  552523.6
parsec3/raytrace  889642.0
parsec3/streamcluster  110978.2
parsec3/swaptions  5762.6
parsec3/vips  31964.0
parsec3/x264  81766.6
splash2x/barnes  1216190.0
splash2x/fft  9853371.8
splash2x/lu_cb  511426.0
splash2x/lu_ncb  511054.0
splash2x/ocean_cp  3399306.6
splash2x/ocean_ncp  3922976.6
splash2x/radiosity  1470337.8
splash2x/radix  2406228.8
splash2x/raytrace  23314.4
splash2x/volrend  44236.2
splash2x/water_nsquared  29446.4
splash2x/water_spatial  664232.0"

keyword="$work_category/$work"
rss_kb=$(echo "$measured_rss_avg" | grep "$keyword" | awk '{print $2}' | \
	awk -F"." '{print $1}')
if [ "$rss_kb" = "" ]
then
	echo "couldn't get rss_kb.  maybe wrong odir? $odir"
	exit 1
fi
full_limit=$((rss_kb * 1024 * 2))
pressure_limit=$((rss_kb * 1024 * 7 / 10))

memcg_root="/sys/fs/cgroup/memory"
if ! mount | grep "$memcg_root"
then
	echo "seems memcg is unmounted at $memcg_root"
	exit 1
fi

memcg_dir="$memcg_root/damon-tests-perf"
if [ ! -d "$memcg_dir" ]
then
	echo "the memcg dir ($memcg_dir) is not set?"
	exit 1
fi

echo "$full_limit" > "$memcg_lim"
if [ ! "$var" = "mprs" ] && [[ ! "$var" == "plurs-"* ]]
then
	exit 0
fi

memcg_lim="$memcg_dir/memory.limit_in_bytes"
while :;
do
	echo "$pressure_limit" > "$memcg_lim"
	sleep 1
	echo "$full_limit" > "$memcg_lim"
	sleep 10
done
