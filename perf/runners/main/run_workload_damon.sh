#!/bin/bash

# exp: perf
# variance: (parsec3|splash2x|ycsb)/<workload>/(orig|thp|ethp|rec|prec)
#     For ycsb, <workload> is the zipfian alpha value.
# $1: <...>/results/<exp>/<variance>/0(0-9)

if [ $# -ne 1 ]
then
	echo "Usage: $0 <output dir>"
	exit 1
fi

ODIR=$1

PARSEC_RUN="$HOME/parsec3_on_ubuntu/run.sh"
SILO_DBTEST="$HOME/silo/out-perf.masstree/benchmarks/dbtest"
DAMO="$HOME/linux/tools/damon/damo"
LBX="$HOME/lazybox"

EXP_DIR="$ODIR/../../../../../../perf/"
var=$(basename $(dirname $ODIR))
work=$(basename $(dirname $(dirname $ODIR)))
work_category=$(basename $(dirname $(dirname $(dirname $ODIR))))
echo $work_category $work

if [ "$work_category" = "splash2x" ]
then
	RUN_CMD="$PARSEC_RUN splash2x.$work"
elif [ "$work_category" = "parsec3" ]
then
	RUN_CMD="$PARSEC_RUN $work"
elif [ "$work_category" = "ycsb" ]
then
	RUN_CMD="$SILO_DBTEST --bench ycsb --verbose --scale-factor 100 \
		--runtime 60 -o --zipfian-alpha=$work"
else
	echo "Unsupported work category $work_category"
	exit 1
fi

RUN_CMD+=" | tee $ODIR/commlog"

echo "RUN_CMD: $RUN_CMD"

if [ "$var" = "orig" ] || [ "$var" = "thp" ]
then
	if [ "$var" = "thp" ]
	then
		sudo $LBX/scripts/turn_thp.sh always
	else
		sudo $LBX/scripts/turn_thp.sh madvise
	fi

	eval $RUN_CMD
	exit
fi

# var is neither 'orig' nor 'thp'
sudo $LBX/scripts/turn_thp.sh madvise
eval $RUN_CMD &

cmdname=$work
if [ "$work_category/$work" = "parsec3/raytrace" ]
then
	cmdname="rtview"
elif [ "$work_category" = "ycsb" ]
then
	cmdname="dbtest"
fi

for i in {1..10}
do
	pid=`pidof $cmdname`
	if [ $? -eq 0 ]
	then
		break
	elif [ $? -ne 0 ] && [ $i -eq 10 ]
	then
		echo "No pid found"
		exit 1
	fi
	echo 'wait for pidof '$cmdname
	sleep 1
done

if [ "$var" = "rec" ]
then
	sudo $DAMO record -o $ODIR/damon.data $pid
elif [ "$var" = "ethp" ]
then
	sudo $DAMO schemes -c $EXP_DIR/schemes/ethp.damos $pid
elif [ "$var" = "prcl" ]
then
	sudo $DAMO schemes -c $EXP_DIR/schemes/prcl.damos $pid
elif [ "$var" = "prec" ]
then
	function prec_for {
		cmdname=$1
		DAMO=$2
		ODIR=$3

		$DAMO record -o $ODIR/damon.data paddr &
		damo_pid=$!

		for i in {1..1200}
		do
			pid=`pidof $cmdname`
			if [ $? -ne 0 ]
			then
				break
			fi

			if [ $i -eq 1200 ]
			then
				echo "Timeout"
				killall $cmdname
			fi
			sleep 3
		done

		kill -SIGINT "$damo_pid"

		i=0
		while true
		do
			on=$(cat /sys/kernel/debug/damon/monitor_on)
			if [ "$on" = "off" ]
			then
				break
			fi
			echo "wait for monitor off $i seconds"
			i=$((i + 1))
			sleep 1
		done
	}
	sudo bash -c "$(declare -f prec_for); prec_for $cmdname $DAMO $ODIR"
else
	echo "Wrong var $var"
	killall $cmdname
	exit 1
fi
