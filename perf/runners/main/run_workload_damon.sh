#!/bin/bash

# exp: perf
# variance: (parsec3|splash2x)/<workload>/(orig|thp|ethp|rec|prec)
# $1: <...>/results/<exp>/<variance>/0(0-9)

if [ $# -ne 1 ]
then
	echo "Usage: $0 <output dir>"
	exit 1
fi

ODIR=$1

PARSEC_RUN="$HOME/parsec3_on_ubuntu/run.sh"
DAMO="$HOME/linux/tools/damon/damo"
LBX="$HOME/lazybox"

EXP_DIR="$ODIR/../../../../../../perf/"
var=$(basename $(dirname $ODIR))
work=$(basename $(dirname $(dirname $ODIR)))
work_category=$(basename $(dirname $(dirname $(dirname $ODIR))))
echo $work_category $work

if [ "$work_category" = "splash2x" ]
then
	PARSEC_RUN+=" splash2x.$work"
elif [ "$work_category" = "parsec3" ]
then
	PARSEC_RUN+=" $work"
fi

PARSEC_RUN+=" | tee $ODIR/commlog"

echo "PARSEC_RUN: $PARSEC_RUN"

if [ "$var" = "orig" ] || [ "$var" = "thp" ]
then
	if [ "$var" = "thp" ]
	then
		sudo $LBX/scripts/turn_thp.sh always
	else
		sudo $LBX/scripts/turn_thp.sh madvise
	fi

	eval $PARSEC_RUN
	exit
fi

# var is neither 'orig' nor 'thp'
sudo $LBX/scripts/turn_thp.sh madvise
eval $PARSEC_RUN &
if [ "$work_category/$work" = "parsec3/raytrace" ]
then
	work="rtview"
fi

for i in {1..10}
do
	pid=`pidof $work`
	if [ $? -eq 0 ]
	then
		break
	elif [ $? -ne 0 ] && [ $i -eq 10 ]
	then
		echo "No pid found"
		exit 1
	fi
	echo 'wait for pidof '$work
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
		work=$1
		DAMO=$2
		ODIR=$3

		$DAMO record -o $ODIR/damon.data paddr &
		damo_pid=$!

		for i in {1..1200}
		do
			pid=`pidof $work`
			if [ $? -ne 0 ]
			then
				break
			fi

			if [ $i -eq 1200 ]
			then
				echo "Timeout"
				killall $work
			fi
			sleep 3
		done

		kill -SIGINT "$damo_pid"
	}
	sudo bash -c "$(declare -f prec_for); prec_for $work $DAMO $ODIR"
else
	echo "Wrong var $var"
	killall $work
	exit 1
fi
